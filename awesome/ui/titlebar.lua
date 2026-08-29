-- Titlebars: what one looks like, and when it is shown.

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local settings = require("config")

client.connect_signal("request::titlebars", function(c)
	-- buttons for the titlebar
	local buttons = gears.table.join(
		awful.button({}, 1, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.move(c)
		end),
		awful.button({}, 3, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.resize(c)
		end)
	)

	awful.titlebar(c):setup({
		{ -- Left
			{
				awful.titlebar.widget.iconwidget(c),
				margins = 6,
				widget = wibox.container.margin,
			},
			buttons = buttons,
			layout = wibox.layout.fixed.horizontal,
		},
		{ -- Middle
			{ -- Title
				align = "center",
				widget = awful.titlebar.widget.titlewidget(c),
			},
			buttons = buttons,
			layout = wibox.layout.flex.horizontal,
		},
		{ -- Right
			awful.titlebar.widget.floatingbutton(c),
			awful.titlebar.widget.ontopbutton(c),
			-- awful.titlebar.widget.minimizebutton(c),
			awful.titlebar.widget.maximizedbutton(c),
			awful.titlebar.widget.closebutton(c),
			layout = wibox.layout.fixed.horizontal(),
		},
		layout = wibox.layout.align.horizontal,
	})
end)

-- Enable sloppy focus, so that focus follows mouse.

-- If not in vm_mode, add titlebars dynamically based on floating status
if not settings.vm_mode then
	-- Add titlebars dynamically based on floating status
	client.connect_signal("manage", function(c)
		-- Enable titlebars for floating windows
		if c.floating then
			awful.titlebar.show(c)
		else
			awful.titlebar.hide(c)
		end
	end)

	-- Update titlebar visibility dynamically when floating state changes
	client.connect_signal("property::floating", function(c)
		if c.floating then
			awful.titlebar.show(c)
		else
			awful.titlebar.hide(c)
		end
	end)
end
