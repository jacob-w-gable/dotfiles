local wibox = require("wibox")
local beautiful = require("beautiful")

local M = {}

--- A textclock. One per screen: each is independently cheap, and lain's
--- calendar attaches to the clock on its own screen.
function M.new()
	return wibox.widget.textclock('<span font="' .. beautiful.font .. '">%a %b %d, %I:%M %p</span>', 60)
end

return M
