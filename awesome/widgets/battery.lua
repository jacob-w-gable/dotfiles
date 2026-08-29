local vicious = require("vicious")
local wibox = require("wibox")
local beautiful = require("beautiful")
local views = require("widgets.views")

local set = views.new()

-- Registered with vicious but never displayed: it exists so there is exactly
-- one battery poll regardless of how many screens show the widget.
local driver = wibox.widget.textbox()

local M = {}

function M.new()
	local textbox = set.add(wibox.widget.textbox())

	set.start_once(function()
		vicious.register(driver, vicious.widgets.bat, function(_, args)
			set.set(string.format('<span font="%s">Bat: %d%%</span>', beautiful.font, args[2]))
			return ""
		end, 61, "BAT0")
	end)

	return wibox.container.margin(textbox, 5, 5, 0, 0)
end

return M
