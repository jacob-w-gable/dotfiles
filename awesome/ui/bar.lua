-- The wibar: per-screen tags, the bar itself, and the widgets on it.

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local lain = require("lain")

local settings = require("config")
local widgets = require("widgets")
local set_wallpaper = require("ui.wallpaper")

return function(args)
	local pomo = args.pomodoro

	awful.screen.connect_for_each_screen(function(s)
		-- Wallpaper
		set_wallpaper(s)

		-- Each screen has its own tag table.
		local names = { "1", "2", "3", "4" }
		local l = awful.layout.suit
		local layouts = { l.tile, l.tile, l.tile, l.tile }
		awful.tag(names, s, layouts)

		-- Create a promptbox for each screen
		s.mypromptbox = awful.widget.prompt()
		-- Create an imagebox widget which will contain an icon indicating which layout we're using.
		-- We need one layoutbox per screen.
		s.mylayoutbox = widgets.layoutbox(s)
		-- Create a taglist widget
		s.mytaglist = widgets.taglist.widget(s)
		-- Create a tasklist widget
		s.mytasklist = widgets.tasklist(s)

		local awful_bg = beautiful.bg_normal
		if settings.opacity then
			awful_bg = beautiful.bg_normal .. "D9"
		end
		-- Create the wibox
		s.mywibox = awful.wibar({ position = "top", screen = s, height = 27, bg = awful_bg })

		local function powerline_left_primary(wgt)
			return {
				widget = wibox.container.margin,
				left = 6,
				right = 6,
				wgt,
			}
		end

		local function powerline_left_secondary(wgt)
			return {
				widget = wibox.container.margin,
				left = -12,
				right = -12,
				{
					widget = wibox.container.background,
					shape = function(cr, width, height)
						gears.shape.powerline(cr, width, height, -height / 2)
					end,
					bg = beautiful.bg_focus,
					fg = beautiful.fg_focus,
					{ widget = wibox.container.margin, left = 18, right = 18, wgt },
				},
			}
		end

		local clock = widgets.clock
		lain.widget.cal({
			attach_to = { clock },
			followtag = true,
			notification_preset = {
				font = beautiful.font,
				bg = beautiful.notification_bg,
				fg = beautiful.fg_normal,
			},
		})

		local function right_widgets()
			if settings.theme == "squircle" then
				return {
					layout = wibox.layout.fixed.horizontal,
					spacing = 24,
					spacing_widget = {
						orientation = "vertical",
						forced_width = 2,
						color = beautiful.bg_focus .. "88",
						widget = wibox.widget.separator,
					},
					pomo.widget(),
					wibox.widget.systray(),
					widgets.caffeine.widget,
					widgets.mpris,
					widgets.volume,
					widgets.battery,
					widgets.weather,
					{
						layout = wibox.layout.fixed.horizontal,
						clock,
						{
							widget = wibox.container.margin,
							right = 12,
							left = 12,
							s.mylayoutbox,
						},
					},
				}
			end

			return { -- Right widgets
				layout = wibox.layout.fixed.horizontal,
				spacing = 12,
				style = {
					shape = gears.shape.powerline,
				},
				spacing_widget = {
					color = "#000000",
					shape = function(cr, width, height)
						gears.shape.powerline(cr, width, height, -height / 2)
					end,
					widget = wibox.widget.separator,
				},
				powerline_left_secondary(pomo.widget()),
				powerline_left_primary(wibox.widget.systray()),
				powerline_left_secondary(widgets.caffeine.widget),
				powerline_left_primary(widgets.mpris),
				powerline_left_secondary(widgets.volume),
				powerline_left_primary(widgets.battery),
				powerline_left_secondary(widgets.weather),
				powerline_left_primary(clock),
				powerline_left_secondary(s.mylayoutbox),
			}
		end

		-- Add widgets to the wibox
		s.mywibox:setup({
			layout = wibox.layout.align.horizontal,
			{ -- Left widgets
				layout = wibox.layout.fixed.horizontal,
				{
					margins = 5,
					widget = wibox.container.margin,
				},
				s.mytaglist,
				{
					margins = 10,
					widget = wibox.container.margin,
				},
				widgets.ramgraph,
				widgets.cpugraph,
				widgets.cputemp,
				{
					margins = 5,
					widget = wibox.container.margin,
				},
				s.mypromptbox,
			},
			{
				layout = wibox.layout.fixed.horizontal,
				{
					widget = wibox.widget.separator,
					orientation = "vertical",
					forced_width = 2,
					color = beautiful.bg_focus .. "88",
				},
				s.mytasklist,
			},
			right_widgets(),
		})
	end)
end
