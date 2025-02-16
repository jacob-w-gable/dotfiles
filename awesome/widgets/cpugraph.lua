local awful = require("awful")
local vicious = require("vicious")

local cpuwidget = awful.widget.graph()
cpuwidget:set_width(50)
cpuwidget:set_background_color("#00000000") -- Transparent background
cpuwidget:set_color({
	type = "linear",
	from = { 0, 0 },
	to = { 50, 0 },
	stops = {
		{ 0, "#FF5656" },
		{ 0.5, "#88A175" },
		{ 1, "#AECF96" },
	},
})
vicious.register(cpuwidget, vicious.widgets.cpu, "$1", 3)

-- Tooltip for CPU widget
local cpu_tooltip = awful.tooltip({
	objects = { cpuwidget }, -- Attach the tooltip to the CPU widget
	timeout = 1, -- Update interval for the tooltip
})

-- Update the tooltip content dynamically
vicious.register(cpuwidget, vicious.widgets.cpu, function(widget, args)
	local cpu_usage = "CPU Usage: " .. args[1] .. "%"
	cpu_tooltip.text = cpu_usage
	return args[1] -- Return the value for the graph
end, 3) -- Update every 3 seconds

return cpuwidget
