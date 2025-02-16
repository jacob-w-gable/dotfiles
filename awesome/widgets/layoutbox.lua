local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")

local function build_layoutbox(s)
	local layoutbox = wibox.widget({
		{
			awful.widget.layoutbox(s),
			margins = 3,
			widget = wibox.container.margin,
		},
		widget = wibox.container.place,
	})
	layoutbox:buttons(gears.table.join(
		awful.button({}, 1, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 3, function()
			awful.layout.inc(-1)
		end),
		awful.button({}, 4, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 5, function()
			awful.layout.inc(-1)
		end)
	))
	return layoutbox
end

return build_layoutbox
