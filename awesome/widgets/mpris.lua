local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local views = require("widgets.views")

local NO_MEDIA = "🎵 No media"

-- Album art is fetched to one stable path rather than a new /tmp file per
-- poll. load_uncached is what makes the imagebox notice the file changed --
-- previously a unique filename per poll was doing that job, and leaking a jpeg
-- every five seconds for as long as the session lasted.
local ART_PATH = gears.filesystem.get_cache_dir() .. "mpris-art.jpg"

local function file_exists(path)
	local f = io.open(path, "r")
	if not f then
		return false
	end
	f:close()
	return true
end

-- Each view is { text, art }; one poller feeds them all.
local set = views.new(function(view, data)
	view.text.markup = string.format('<span font="%s">%s</span>', beautiful.font, gears.string.xml_escape(data.text))
	view.art.image = data.art and gears.surface.load_uncached(data.art) or nil
end, { text = NO_MEDIA, art = nil })

-- Text and art are pushed independently: the track name should appear as soon
-- as playerctl answers, not wait on the album art download.
local shown = { text = NO_MEDIA, art = nil }
local last_art_url

local function push()
	set.set({ text = shown.text, art = shown.art })
end

local function show_nothing()
	shown.text, shown.art, last_art_url = NO_MEDIA, nil, nil
	push()
end

local function poll()
	awful.spawn.easy_async_with_shell("playerctl -l", function(players)
		if not players:match("spotify") then
			return show_nothing()
		end

		awful.spawn.easy_async_with_shell(
			[[playerctl -p spotify metadata --format '{{xesam:artist}}|||{{xesam:title}}|||{{mpris:artUrl}}' 2>/dev/null]],
			function(stdout)
				local artist, title, art_url = stdout:match("^(.-)|||(.-)|||(.-)$")

				local function trim(s)
					return s and s:match("^%s*(.-)%s*$") or ""
				end

				artist, title, art_url = trim(artist), trim(title), trim(art_url)

				if artist == "" or title == "" then
					return show_nothing()
				end

				shown.text = artist .. " - " .. title
				push()

				if not art_url:match("^https?://") then
					shown.art, last_art_url = nil, nil
					return push()
				end

				-- Only re-fetch when the track actually changed.
				if art_url == last_art_url and file_exists(ART_PATH) then
					shown.art = ART_PATH
					return push()
				end

				last_art_url = art_url
				awful.spawn.easy_async_with_shell(
					string.format("curl -s -L -o %s '%s'", ART_PATH, art_url),
					function()
						shown.art = file_exists(ART_PATH) and ART_PATH or nil
						push()
					end
				)
			end
		)
	end)
end

local M = {}

function M.new()
	local art = wibox.widget({
		widget = wibox.widget.imagebox,
		resize = true,
		forced_width = beautiful.dpi(32),
		forced_height = beautiful.dpi(32),
	})

	local text = wibox.widget.textbox()

	set.add(text, { text = text, art = art })

	local widget = wibox.widget({
		art,
		{
			text,
			margins = beautiful.dpi(4),
			widget = wibox.container.margin,
		},
		layout = wibox.layout.fixed.horizontal,
		buttons = gears.table.join(
			awful.button({}, 1, function()
				awful.spawn("playerctl -p spotify play-pause")
			end),
			awful.button({}, 4, function()
				awful.spawn("playerctl -p spotify next")
			end),
			awful.button({}, 5, function()
				awful.spawn("playerctl -p spotify previous")
			end)
		),
	})

	set.start_once(function()
		gears.timer({ timeout = 5, autostart = true, callback = poll })
		poll()
	end)

	return widget
end

return M
