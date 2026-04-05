local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local colors = require("theme.colors")
local settings = require("settings")

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
	if settings.theme == "squircle" then
		return awful.widget.taglist({
			screen = s,
			filter = awful.widget.taglist.filter.all,
			widget_template = {
				{
					{
						{
							id = "text_role",
							widget = wibox.widget.textbox,
						},
						left = 10,
						right = 10,
						top = 2,
						bottom = 2,
						widget = wibox.container.margin,
					},
					id = "background_role",
					widget = wibox.container.background,
				},
				top = 3,
				bottom = 3,
				widget = wibox.container.margin,
			},
			buttons = taglist_buttons,
		})
	end

	-- Default to powerline style
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

local function theme(style)
	if settings.theme == "squircle" then
		style.taglist_bg_occupied = colors.highlight_color .. "33"
		style.taglist_bg_empty = colors.highlight_color .. "33"
		style.taglist_fg_focus = colors.background_color
		style.taglist_shape = function(cr, w, h)
			gears.shape.rounded_rect(cr, w, h, 6)
		end
		style.taglist_spacing = 6
		return style
	end

	-- Default to powerline style
	style.taglist_shape = gears.shape.powerline
	style.taglist_spacing = -12
	return style
end

return {
	widget = build_taglist,
	theme = theme,
}
