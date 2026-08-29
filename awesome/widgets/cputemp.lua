local vicious = require("vicious")
local wibox = require("wibox")
local beautiful = require("beautiful")
local views = require("widgets.views")

local set = views.new()

-- See battery.lua: drives a single poll, never displayed.
local driver = wibox.widget.textbox()

local M = {}

function M.new()
	local textbox = set.add(wibox.widget.textbox())

	set.start_once(function()
		vicious.register(driver, vicious.widgets.thermal, function(_, args)
			set.set(string.format('<span font="%s">%d°C</span>', beautiful.font, args[1]))
			return ""
		end, 7, "thermal_zone0")
	end)

	return wibox.container.margin(textbox, 20, 10, 0, 0)
end

return M
