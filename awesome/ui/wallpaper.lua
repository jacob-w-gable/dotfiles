-- Wallpaper drawing.

local beautiful = require("beautiful")
local gears = require("gears")

local function set_wallpaper(s)
	-- Wallpaper
	if beautiful.wallpaper then
		local wallpaper = beautiful.wallpaper
		-- If wallpaper is a function, call it with the screen
		if type(wallpaper) == "function" then
			wallpaper = wallpaper(s)
		end
		-- false = honour the aspect ratio: scale by max(aspect_w, aspect_h)
		-- and centre, which is what `feh --bg-fill` did.
		gears.wallpaper.maximized(wallpaper, s, false)
	end
end



-- Redraw when a screen's geometry changes, e.g. a resolution change.
screen.connect_signal("property::geometry", set_wallpaper)

return set_wallpaper
