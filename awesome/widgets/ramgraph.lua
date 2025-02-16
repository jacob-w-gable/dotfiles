local vicious = require("vicious")
local awful = require("awful")

-- Create the RAM graph widget
local ramwidget = awful.widget.graph()
ramwidget:set_width(50)
ramwidget:set_background_color("#00000000") -- Transparent background
ramwidget:set_color({
	type = "linear",
	from = { 0, 0 },
	to = { 50, 0 },
	stops = {
		{ 0, "#56A3FF" },
		{ 0.5, "#75A188" },
		{ 1, "#96CFAE" },
	},
})

-- Register RAM widget with vicious
vicious.register(ramwidget, vicious.widgets.mem, "$1", 3) -- $1 is the percentage of RAM used

-- Tooltip for RAM widget
local ram_tooltip = awful.tooltip({
	objects = { ramwidget }, -- Attach the tooltip to the RAM widget
	timeout = 1, -- Update interval for the tooltip
})

-- Update the tooltip content dynamically
vicious.register(ramwidget, vicious.widgets.mem, function(widget, args)
	local ram_details = string.format(
		"RAM: %d%% (%d MiB / %d MiB)\nSwap: %d%% (%d MiB / %d MiB)",
		args[1], -- RAM usage percentage
		args[2], -- RAM used in MiB
		args[3], -- Total RAM in MiB
		args[5], -- Swap usage percentage
		args[6], -- Swap used in MiB
		args[7] -- Total Swap in MiB
	)
	ram_tooltip.text = ram_details
	return args[1] -- Return the value for the graph
end, 3) -- Update every 3 seconds

return ramwidget
