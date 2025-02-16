-- Tasklist widget buidler function
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")

local tasklist_buttons = gears.table.join(
	awful.button({}, 1, function(c)
		if c == client.focus then
			c.minimized = true
		else
			c:emit_signal("request::activate", "tasklist", { raise = true })
		end
	end),
	awful.button({}, 3, function()
		awful.menu.client_list({ theme = { width = 250 } })
	end),
	awful.button({}, 4, function()
		awful.client.focus.byidx(1)
	end),
	awful.button({}, 5, function()
		awful.client.focus.byidx(-1)
	end)
)

local function build_tasklist(s)
	return awful.widget.tasklist({
		screen = s,
		filter = awful.widget.tasklist.filter.currenttags,
		buttons = tasklist_buttons,
		style = {
			shape = function(cr, width, height)
				gears.shape.parallelogram(cr, width, height, width - height / 3)
			end,
		},
		layout = {
			spacing = 10,
			spacing_widget = {
				color = "#000000",
				shape = function(cr, width, height)
					gears.shape.parallelogram(cr, width, height, width - height / 3)
				end,
				widget = wibox.widget.separator,
			},
			layout = wibox.layout.fixed.horizontal,
		},
		widget_template = {
			{
				{
					{
						{
							{
								id = "icon_role",
								widget = wibox.widget.imagebox,
							},
							margins = 5,
							widget = wibox.container.margin,
						},
						{
							{
								id = "text_role",
								widget = wibox.widget.textbox,
							},
							left = 8,
							widget = wibox.container.margin,
						},
						layout = wibox.layout.fixed.horizontal,
					},
					left = 15,
					right = 15,
					widget = wibox.container.margin,
				},
				id = "background_role",
				widget = wibox.container.background,
			},
			widget = wibox.container.margin,
			left = -8,
			right = -8,
		},
	})
end

return build_tasklist
