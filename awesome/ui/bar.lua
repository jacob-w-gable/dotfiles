-- The wibar: per-screen tags, the bar itself, and the widgets on it.

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local lain = require("lain")

local alpha = require("theme.alpha")
local variants = require("theme.variants")
local battery = require("widgets.battery")
local caffeine = require("widgets.caffeine")
local clock_widget = require("widgets.clock")
local cpugraph = require("widgets.cpugraph")
local cputemp = require("widgets.cputemp")
local layoutbox = require("widgets.layoutbox")
local mpris = require("widgets.mpris")
local ramgraph = require("widgets.ramgraph")
local taglist = require("widgets.taglist")
local tasklist = require("widgets.tasklist")
local volume = require("widgets.volume")
local weather = require("widgets.weather")
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
		s.mylayoutbox = layoutbox.new(s)
		-- Create a taglist widget
		s.mytaglist = taglist.new(s)
		-- Create a tasklist widget
		s.mytasklist = tasklist.new(s)

		local awful_bg = alpha(beautiful.bg_normal, "bar")
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

		local clock = clock_widget.new()
		lain.widget.cal({
			attach_to = { clock },
			followtag = true,
			notification_preset = {
				font = beautiful.font,
				bg = beautiful.notification_bg,
				fg = beautiful.fg_normal,
			},
		})

		-- The bar's right-hand side, in order. Defined once; each theme variant
		-- only decides how to decorate it, so adding a widget is a one-line
		-- change rather than an edit to two parallel lists that must agree.
		--
		-- The pomodoro and the systray are single objects by nature -- one
		-- timer, and an X selection awesome can only own once -- so they go on
		-- the primary screen only. Everything else is built per screen.
		local function right_widget_list()
			local list = {}

			if s == screen.primary then
				list[#list + 1] = { name = "pomodoro", widget = pomo.widget() }
				list[#list + 1] = { name = "systray", widget = wibox.widget.systray() }
			end

			list[#list + 1] = { name = "caffeine", widget = caffeine.new() }
			list[#list + 1] = { name = "mpris", widget = mpris.new() }
			list[#list + 1] = { name = "volume", widget = volume.new() }
			list[#list + 1] = { name = "battery", widget = battery.new() }
			list[#list + 1] = { name = "weather", widget = weather.new() }
			list[#list + 1] = { name = "clock", widget = clock }
			list[#list + 1] = { name = "layoutbox", widget = s.mylayoutbox }

			return list
		end

		local function right_widgets()
			local list = right_widget_list()

			if variants.is_squircle() then
				local container = {
					layout = wibox.layout.fixed.horizontal,
					spacing = 24,
					spacing_widget = {
						orientation = "vertical",
						forced_width = 2,
						color = alpha(beautiful.bg_focus, "separator"),
						widget = wibox.widget.separator,
					},
				}

				for _, entry in ipairs(list) do
					if entry.name == "layoutbox" then
						-- Shares the clock's slot rather than getting a
						-- separator of its own.
						container[#container] = {
							layout = wibox.layout.fixed.horizontal,
							container[#container],
							{
								widget = wibox.container.margin,
								right = 12,
								left = 12,
								entry.widget,
							},
						}
					else
						container[#container + 1] = entry.widget
					end
				end

				return container
			end

			local container = {
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
			}

			-- Alternating fills, starting on the secondary colour.
			for i, entry in ipairs(list) do
				local wrap = (i % 2 == 1) and powerline_left_secondary or powerline_left_primary
				container[#container + 1] = wrap(entry.widget)
			end

			return container
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
				ramgraph.new(),
				cpugraph.new(),
				cputemp.new(),
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
					color = alpha(beautiful.bg_focus, "separator"),
				},
				s.mytasklist,
			},
			right_widgets(),
		})
	end)
end
