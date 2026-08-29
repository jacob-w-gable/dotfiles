local awful = require("awful")
local wibox = require("wibox")
local vicious = require("vicious")
local views = require("widgets.views")

local set = views.new(function(view, data)
	-- The graph's max_value is 1, so a percentage has to be normalised before
	-- add_value or it clamps to a permanently full graph. vicious does this
	-- itself (topercent, vicious/init.lua:102); feeding the graph directly
	-- means doing it here.
	view.graph:add_value(data.value / 100)
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
			{ 0, "#56A3FF" },
			{ 0.5, "#75A188" },
			{ 1, "#96CFAE" },
		},
	})

	local tooltip = awful.tooltip({ objects = { graph }, timeout = 1 })
	set.add(graph, { graph = graph, tooltip = tooltip })

	set.start_once(function()
		vicious.register(driver, vicious.widgets.mem, function(_, args)
			set.set({
				value = args[1],
				text = string.format(
					"RAM: %d%% (%d MiB / %d MiB)\nSwap: %d%% (%d MiB / %d MiB)",
					args[1],
					args[2],
					args[3],
					args[5],
					args[6],
					args[7]
				),
			})
			return 0
		end, 3)
	end)

	return graph
end

return M
