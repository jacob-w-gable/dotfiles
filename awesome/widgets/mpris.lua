local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local lfs = require("lfs")

-- Helper to check if a file exists
local function file_exists(path)
	return lfs.attributes(path, "mode") == "file"
end

-- Album art widget
local art_widget = wibox.widget({
	widget = wibox.widget.imagebox,
	resize = true,
	forced_width = 32,
	forced_height = 32,
})

-- Text widget
local text_widget = wibox.widget({
	{
		id = "text",
		widget = wibox.widget.textbox,
		text = "🎵 No media",
	},
	margins = 4,
	widget = wibox.container.margin,
})

-- Main widget container
local media_widget = wibox.widget({
	art_widget,
	text_widget,
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

-- Timer to update every 5 seconds
gears.timer({
	timeout = 5,
	autostart = true,
	callback = function()
		-- Check if Spotify is running
		awful.spawn.easy_async_with_shell("playerctl -l", function(players)
			if not players:match("spotify") then
				text_widget:get_children_by_id("text")[1].text = "🎵 No media"
				art_widget.image = nil
				return
			end

			-- Fetch metadata
			awful.spawn.easy_async_with_shell(
				[[playerctl -p spotify metadata --format '{{xesam:artist}}|||{{xesam:title}}|||{{mpris:artUrl}}' 2>/dev/null]],
				function(stdout)
					local artist, title, art_url = stdout:match("^(.-)|||(.-)|||(.-)$")

					local function trim(s)
						return s and s:match("^%s*(.-)%s*$") or ""
					end

					artist = trim(artist)
					title = trim(title)
					art_url = trim(art_url)

					if artist ~= "" and title ~= "" then
						text_widget:get_children_by_id("text")[1].text = artist .. " - " .. title
					else
						text_widget:get_children_by_id("text")[1].text = "🎵 No media"
						art_widget.image = nil
						return
					end

					if art_url:match("^https?://") then
						-- Use track ID or timestamp to create unique filename
						local unique_path = "/tmp/awesomewm_album_art_" .. tostring(os.time()) .. ".jpg"

						awful.spawn.easy_async_with_shell(
							string.format("curl -s -L -o %s '%s'", unique_path, art_url),
							function()
								if file_exists(unique_path) then
									art_widget.image = unique_path
								end
							end
						)
					else
						art_widget.image = nil
					end
				end
			)
		end)
	end,
})

return media_widget
