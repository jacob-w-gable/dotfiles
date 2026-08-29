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

	-- Only touch the imagebox when the art has actually changed. The file path
	-- is stable now, so imagebox's own "same image" short-circuit cannot help:
	-- load_uncached returns a fresh surface every call, which would re-decode
	-- the jpeg and invalidate the bar on every push, twice per poll, forever.
	if data.art_token ~= view.art_token then
		view.art_token = data.art_token
		view.art.image = data.art and gears.surface.load_uncached(data.art) or nil
	end
end, { text = NO_MEDIA, art = nil })

-- Text and art are pushed independently: the track name should appear as soon
-- as playerctl answers, not wait on the album art download.
-- art_token changes only when the artwork does, so views can tell a genuine
-- change from a repeated push of the same track.
local shown = { text = NO_MEDIA, art = nil, art_token = nil }
local last_art_url

local function push()
	set.set({ text = shown.text, art = shown.art, art_token = shown.art_token })
end

local function set_art(path, token)
	shown.art, shown.art_token = path, token
end

local function show_nothing()
	shown.text = NO_MEDIA
	set_art(nil, nil)
	last_art_url = nil
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
					set_art(nil, nil)
					last_art_url = nil
					return push()
				end

				-- Already downloaded for this track: nothing more to do.
				if art_url == last_art_url and file_exists(ART_PATH) then
					return
				end

				awful.spawn.easy_async_with_shell(
					string.format("curl -s -L -o %s '%s'", ART_PATH, art_url),
					function()
						-- Recorded here rather than before the download: the
						-- path is shared now, so claiming the url up front lets
						-- the next poll hand out a file curl is still writing.
						last_art_url = art_url
						set_art(file_exists(ART_PATH) and ART_PATH or nil, art_url)
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
