local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")

local taglist_buttons = gears.table.join(
	awful.button({}, 1, function(t)
		t:view_only()
	end),
	awful.button({ modkey }, 1, function(t)
		if client.focus then
			client.focus:move_to_tag(t)
		end
	end),
	awful.button({}, 3, awful.tag.viewtoggle),
	awful.button({ modkey }, 3, function(t)
		if client.focus then
			client.focus:toggle_tag(t)
		end
	end),
	awful.button({}, 4, function(t)
		awful.tag.viewnext(t.screen)
	end),
	awful.button({}, 5, function(t)
		awful.tag.viewprev(t.screen)
	end)
)

local function build_taglist(s)
	return awful.widget.taglist({
		screen = s,
		filter = awful.widget.taglist.filter.all,
		style = {
			shape = gears.shape.powerline,
		},
		layout = {
			spacing = -12,
			spacing_widget = {
				color = "#000000",
				shape = gears.shape.powerline,
				widget = wibox.widget.separator,
			},
			layout = wibox.layout.fixed.horizontal,
		},
		widget_template = {
			{
				{
					id = "text_role",
					widget = wibox.widget.textbox,
				},
				left = 20,
				right = 20,
				widget = wibox.container.margin,
			},
			id = "background_role",
			widget = wibox.container.background,
		},
		buttons = taglist_buttons,
	})
end

return build_taglist
