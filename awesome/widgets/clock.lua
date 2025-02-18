local wibox = require("wibox")
local theme = require("theme.theme")

local mytextclock = wibox.widget.textclock('<span font="' .. theme.font .. '">%a %b %d, %I:%M %p</span>', 60)

return mytextclock
