local awful = require("awful")
local wibox = require("wibox")
local vicious = require("vicious")
local views = require("widgets.views")

-- Each view is { graph, tooltip }; one vicious registration feeds them all.
local set = views.new(function(view, data)
	view.graph:add_value(data.value)
	view.tooltip.text = data.text
end)

local driver = wibox.widget.graph()

local M = {}

function M.new()
	local graph = wibox.widget.graph()
	graph:set_width(50)
	graph:set_background_color("#00000000")
	graph:set_color({
		type = "linear",
		from = { 0, 0 },
		to = { 50, 0 },
		stops = {
			{ 0, "#FF5656" },
			{ 0.5, "#88A175" },
			{ 1, "#AECF96" },
		},
	})

	local tooltip = awful.tooltip({ objects = { graph }, timeout = 1 })
	set.add(graph, { graph = graph, tooltip = tooltip })

	set.start_once(function()
		vicious.register(driver, vicious.widgets.cpu, function(_, args)
			set.set({ value = args[1], text = "CPU Usage: " .. args[1] .. "%" })
			return 0
		end, 3)
	end)

	return graph
end

return M
