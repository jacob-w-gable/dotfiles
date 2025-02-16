-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Personal settings
local settings = require("settings")
-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local config_path = require("gears.filesystem").get_configuration_dir()
-- Widget and layout library
local wibox = require("wibox")
local vicious = require("vicious")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- Load Debian menu entries
local debian = require("debian.menu")
local has_fdo, freedesktop = pcall(require, "freedesktop")

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(config_path .. "theme.lua")

-- Configure lock screen and lock screen wallpaper
local lock_screen_fg = beautiful.fg_focus:sub(2)
local lock_screen_hl = beautiful.bg_focus:sub(2)
local lock_screen_bg = beautiful.bg_normal:sub(2)
local lock_screen_wp_path = "/usr/share/wallpapers/jacob-w-gable/contents/images_dark/wallpaper1.png"

local lock_command = "i3lock -i "
	.. lock_screen_wp_path
	.. " -F -f --indicator --clock"
	.. " --ring-color="
	.. lock_screen_bg
	.. " --ringver-color="
	.. lock_screen_fg
	.. " --insidever-color="
	.. lock_screen_bg
	.. " --insidewrong-color="
	.. lock_screen_bg
	.. " --verif-color="
	.. lock_screen_fg
	.. " --wrong-color="
	.. lock_screen_fg
	.. " --time-color="
	.. lock_screen_fg
	.. " --date-color="
	.. lock_screen_hl
	.. " --greeter-color="
	.. lock_screen_hl
	.. " --layout-color="
	.. lock_screen_hl
	.. " --keyhl-color="
	.. lock_screen_fg
	.. ' --time-str="%H:%M" --date-str="%A, %Y-%m-%d" --wrong-text="Incorrect" --noinput-text="No input" '
	.. '--verif-text="Verifying..."'

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = "Oops, there were errors during startup!",
		text = awesome.startup_errors,
	})
end

-- Handle runtime errors after startup
do
	local in_error = false
	awesome.connect_signal("debug::error", function(err)
		-- Make sure we don't go into an endless error loop
		if in_error then
			return
		end
		in_error = true

		naughty.notify({
			preset = naughty.config.presets.critical,
			title = "Oops, an error happened!",
			text = tostring(err),
		})
		in_error = false
	end)
end
-- }}}

-- This is used later as the default terminal and editor to run.
terminal = "kitty"
editor = os.getenv("EDITOR") or "nvim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
	awful.layout.suit.floating,
	awful.layout.suit.tile,
	awful.layout.suit.tile.left,
	awful.layout.suit.tile.bottom,
	awful.layout.suit.tile.top,
	awful.layout.suit.fair,
	awful.layout.suit.fair.horizontal,
	awful.layout.suit.spiral,
	awful.layout.suit.spiral.dwindle,
	awful.layout.suit.max,
	awful.layout.suit.max.fullscreen,
	awful.layout.suit.magnifier,
	awful.layout.suit.corner.nw,
	-- awful.layout.suit.corner.ne,
	-- awful.layout.suit.corner.sw,
	-- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
	{
		"hotkeys",
		function()
			hotkeys_popup.show_help(nil, awful.screen.focused())
		end,
	},
	{ "manual", terminal .. " -e man awesome" },
	{ "edit config", editor_cmd .. " " .. awesome.conffile },
	{ "restart", awesome.restart },
	{
		"quit",
		function()
			awesome.quit()
		end,
	},
}

local menu_awesome = { "awesome", myawesomemenu, beautiful.awesome_icon }
local menu_terminal = { "open terminal", terminal }

if has_fdo then
	mymainmenu = freedesktop.menu.build({
		before = { menu_awesome },
		after = { menu_terminal },
	})
else
	mymainmenu = awful.menu({
		items = {
			menu_awesome,
			{ "Debian", debian.menu.Debian_menu.Debian },
			menu_terminal,
		},
	})
end

-- Create the RAM graph widget
ramwidget = awful.widget.graph()
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

cpuwidget = awful.widget.graph()
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

-- Create a text widget for the battery
batwidget = wibox.widget.textbox()
-- Add margin around the battery widget
batwidget_with_margin = wibox.container.margin(batwidget, 5, 5, 0, 0) -- Left, Right, Top, Bottom margins
-- Register the battery widget with vicious
vicious.register(batwidget, vicious.widgets.bat, "Bat: $2%", 61, "BAT0") -- $2 for battery percentage, %% to display %

-- Create a weather widget
local weather_widget = wibox.widget.textbox()
weather_widget_with_margin = wibox.container.margin(weather_widget, 5, 5, 0, 0)

vicious.register(weather_widget, vicious.widgets.weather, "${tempf}°F (HSV)", 600, "KHSV")

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock("%a %b %d, %I:%M %p")

-- Create the volume widget
local volume_widget = wibox.widget({
	widget = wibox.container.background,
	{
		widget = wibox.container.margin,
		margins = 4,
		{
			widget = wibox.widget.textbox,
			id = "volume_text",
			text = "Vol: 0%", -- Initial placeholder
		},
	},
})

-- Function to update volume
local function update_volume(widget)
	awful.spawn.easy_async_with_shell("pactl get-sink-volume @DEFAULT_SINK@", function(stdout)
		local volume = stdout:match("(%d+)%%")
		widget:get_children_by_id("volume_text")[1].text = "Vol: " .. (volume or "0") .. "%"
	end)
end

-- Update volume on creation and when the volume changes
update_volume(volume_widget)
awesome.connect_signal("volume::update", function()
	update_volume(volume_widget)
end)

-- Bind keys or buttons to control volume
volume_widget:buttons(gears.table.join(
	awful.button({}, 4, function() -- Scroll up
		awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%", false)
		awesome.emit_signal("volume::update")
	end),
	awful.button({}, 5, function() -- Scroll down
		awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%", false)
		awesome.emit_signal("volume::update")
	end),
	awful.button({}, 1, function() -- Left click to toggle mute
		awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle", false)
		awesome.emit_signal("volume::update")
	end)
))

-- Automatically update the widget periodically
gears.timer({
	timeout = 5,
	autostart = true,
	callback = function()
		awesome.emit_signal("volume::update")
	end,
})

local prompt_popup_bg = beautiful.bg_normal
local prompt_popup_border = beautiful.border_focus
if settings.opacity then
	prompt_popup_bg = prompt_popup_bg .. "B3"
	prompt_popup_border = prompt_popup_border .. "B3"
end

-- Create a floating popup wibox
local prompt_popup = wibox({
	width = 500, -- Adjust width as needed
	height = 60, -- Adjust height as needed
	ontop = true,
	visible = false,
	bg = prompt_popup_bg,
	border_color = prompt_popup_border,
	border_width = beautiful.border_width,
	shape = function(cr, width, height)
		gears.shape.rounded_rect(cr, width, height, 20) -- Rounded corners
	end,
})

-- Create the prompt widget
local promptbox = awful.widget.prompt()

-- Add the promptbox to the wibox
prompt_popup:setup({
	{
		promptbox,
		widget = wibox.container.margin,
		margins = 10,
	},
	layout = wibox.layout.fixed.horizontal,
})

-- Function to show the prompt at the center of the screen
local function show_prompt()
	local screen_geo = awful.screen.focused().geometry
	prompt_popup.x = screen_geo.x + (screen_geo.width - prompt_popup.width) / 2
	prompt_popup.y = screen_geo.y + (screen_geo.height - prompt_popup.height) / 3
	prompt_popup.visible = true
	awful.prompt.run({
		prompt = "Run: ",
		textbox = promptbox.widget,
		exe_callback = function(cmd)
			if cmd and cmd ~= "" then
				awful.spawn(cmd)
			end
			prompt_popup.visible = false -- Hide after command
		end,
		history_path = awful.util.get_cache_dir() .. "/history_run",
		done_callback = function()
			prompt_popup.visible = false
		end, -- Hide when dismissed
	})
end

-- Create a wibox for each screen and add it
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

local function set_wallpaper(s)
	-- Wallpaper
	if beautiful.wallpaper then
		local wallpaper = beautiful.wallpaper
		-- If wallpaper is a function, call it with the screen
		if type(wallpaper) == "function" then
			wallpaper = wallpaper(s)
		end
		gears.wallpaper.maximized(wallpaper, s, true)
	end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
	-- Wallpaper
	set_wallpaper(s)

	-- Each screen has its own tag table.
	local names = { "Dev", "Comm", "Media", "Free" }
	local l = awful.layout.suit
	local layouts = { l.tile, l.tile, l.tile, l.floating }
	awful.tag(names, s, layouts)

	-- Create a promptbox for each screen
	s.mypromptbox = awful.widget.prompt()
	-- Create an imagebox widget which will contain an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	s.mylayoutbox = wibox.widget({
		{
			awful.widget.layoutbox(s),
			margins = 3,
			widget = wibox.container.margin,
		},
		widget = wibox.container.place,
	})
	s.mylayoutbox:buttons(gears.table.join(
		awful.button({}, 1, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 3, function()
			awful.layout.inc(-1)
		end),
		awful.button({}, 4, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 5, function()
			awful.layout.inc(-1)
		end)
	))
	-- Create a taglist widget
	s.mytaglist = awful.widget.taglist({
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

	-- Create a tasklist widget
	s.mytasklist = awful.widget.tasklist({
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

	-- Add widgets to the wibox
	s.mywibox:setup({
		layout = wibox.layout.align.horizontal,
		{ -- Left widgets
			layout = wibox.layout.fixed.horizontal,
			{
				margins = 5,
				widget = wibox.container.margin,
			},
			-- mylauncher,
			s.mytaglist,
			{
				margins = 5,
				widget = wibox.container.margin,
			},
			ramwidget,
			cpuwidget,
			{
				margins = 5,
				widget = wibox.container.margin,
			},
			s.mypromptbox,
		},
		s.mytasklist,
		{ -- Right widgets
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
			powerline_left_primary(wibox.widget.systray()),
			powerline_left_secondary(volume_widget),
			powerline_left_primary(batwidget_with_margin),
			powerline_left_secondary(weather_widget_with_margin),
			powerline_left_primary(mytextclock),
			powerline_left_secondary(s.mylayoutbox),
		},
	})
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
	awful.button({}, 3, function()
		mymainmenu:toggle()
	end),
	awful.button({}, 4, awful.tag.viewnext),
	awful.button({}, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
	awful.key({ modkey }, "s", hotkeys_popup.show_help, { description = "show help", group = "awesome" }),
	awful.key({ modkey }, "Left", awful.tag.viewprev, { description = "view previous", group = "tag" }),
	awful.key({ modkey }, "Right", awful.tag.viewnext, { description = "view next", group = "tag" }),
	awful.key({ modkey }, "Escape", awful.tag.history.restore, { description = "go back", group = "tag" }),

	awful.key({ modkey }, "j", function()
		awful.client.focus.byidx(-1)
	end, { description = "focus next by index", group = "client" }),
	awful.key({ modkey }, "k", function()
		awful.client.focus.byidx(1)
	end, { description = "focus previous by index", group = "client" }),
	awful.key({ modkey }, "w", function()
		mymainmenu:show()
	end, { description = "show main menu", group = "awesome" }),

	-- Layout manipulation
	awful.key({ modkey, "Shift" }, "j", function()
		awful.client.swap.byidx(1)
	end, { description = "swap with next client by index", group = "client" }),
	awful.key({ modkey, "Shift" }, "k", function()
		awful.client.swap.byidx(-1)
	end, { description = "swap with previous client by index", group = "client" }),
	awful.key({ modkey, "Control" }, "j", function()
		awful.screen.focus_relative(1)
	end, { description = "focus the next screen", group = "screen" }),
	awful.key({ modkey, "Control" }, "k", function()
		awful.screen.focus_relative(-1)
	end, { description = "focus the previous screen", group = "screen" }),
	awful.key({ modkey }, "u", awful.client.urgent.jumpto, { description = "jump to urgent client", group = "client" }),
	awful.key({ modkey }, "Tab", function()
		awful.client.focus.history.previous()
		if client.focus then
			client.focus:raise()
		end
	end, { description = "go back", group = "client" }),

	-- Standard program
	awful.key({ modkey }, "Return", function()
		awful.spawn(terminal)
	end, { description = "open a terminal", group = "launcher" }),
	awful.key({ modkey, "Control" }, "r", awesome.restart, { description = "reload awesome", group = "awesome" }),
	awful.key({ modkey, "Shift" }, "q", awesome.quit, { description = "quit awesome", group = "awesome" }),

	awful.key({ modkey }, "l", function()
		awful.tag.incmwfact(0.05)
	end, { description = "increase master width factor", group = "layout" }),
	awful.key({ modkey }, "h", function()
		awful.tag.incmwfact(-0.05)
	end, { description = "decrease master width factor", group = "layout" }),
	awful.key({ modkey, "Shift" }, "h", function()
		awful.tag.incnmaster(1, nil, true)
	end, { description = "increase the number of master clients", group = "layout" }),
	awful.key({ modkey, "Shift" }, "l", function()
		awful.tag.incnmaster(-1, nil, true)
	end, { description = "decrease the number of master clients", group = "layout" }),
	awful.key({ modkey, "Control" }, "h", function()
		awful.tag.incncol(1, nil, true)
	end, { description = "increase the number of columns", group = "layout" }),
	awful.key({ modkey, "Control" }, "l", function()
		awful.tag.incncol(-1, nil, true)
	end, { description = "decrease the number of columns", group = "layout" }),
	awful.key({ modkey }, "space", function()
		awful.layout.inc(1)
	end, { description = "select next", group = "layout" }),
	awful.key({ modkey, "Shift" }, "space", function()
		awful.layout.inc(-1)
	end, { description = "select previous", group = "layout" }),

	awful.key({ modkey, "Control" }, "n", function()
		local c = awful.client.restore()
		-- Focus restored client
		if c then
			c:emit_signal("request::activate", "key.unminimize", { raise = true })
		end
	end, { description = "restore minimized", group = "client" }),

	-- Prompt
	awful.key({ modkey }, "r", show_prompt, { description = "run prompt", group = "launcher" }),
	-- awful.key({ modkey }, "r", function()
	-- 	awful.screen.focused().mypromptbox:run()
	-- end, { description = "run prompt", group = "launcher" }),

	awful.key({ modkey }, "x", function()
		awful.prompt.run({
			prompt = "Run Lua code: ",
			textbox = awful.screen.focused().mypromptbox.widget,
			exe_callback = awful.util.eval,
			history_path = awful.util.get_cache_dir() .. "/history_eval",
		})
	end, { description = "lua execute prompt", group = "awesome" }),
	-- Menubar
	awful.key({ modkey }, "p", function()
		menubar.show()
	end, { description = "show the menubar", group = "launcher" }),

	awful.key({}, "XF86AudioRaiseVolume", function()
		awful.spawn("amixer -q sset Master 5%+")
	end, { description = "increase volume", group = "media" }),

	awful.key({}, "XF86AudioLowerVolume", function()
		awful.spawn("amixer -q sset Master 5%-")
	end, { description = "decrease volume", group = "media" }),

	awful.key({}, "XF86AudioMute", function()
		awful.spawn("amixer -q sset Master toggle")
	end, { description = "mute volume", group = "media" }),

	-- Media playback
	awful.key({}, "XF86AudioPlay", function()
		awful.spawn("playerctl play-pause")
	end, { description = "play/pause media", group = "media" }),

	awful.key({}, "XF86AudioNext", function()
		awful.spawn("playerctl next")
	end, { description = "next track", group = "media" }),

	awful.key({}, "XF86AudioPrev", function()
		awful.spawn("playerctl previous")
	end, { description = "previous track", group = "media" }),

	awful.key({}, "XF86MonBrightnessUp", function()
		awful.spawn("xbacklight -inc 10")
	end, { description = "increase brightness", group = "media" }),

	awful.key({}, "XF86MonBrightnessDown", function()
		awful.spawn("xbacklight -dec 10")
	end, { description = "decrease brightness", group = "media" }),

	awful.key({ "Mod4" }, "'", function()
		awful.spawn("xset s activate")
	end, { description = "lock screen", group = "hotkeys" })
)

clientkeys = gears.table.join(
	awful.key({ modkey }, "f", function(c)
		c.fullscreen = not c.fullscreen
		c:raise()
	end, { description = "toggle fullscreen", group = "client" }),
	awful.key({ modkey, "Shift" }, "c", function(c)
		c:kill()
	end, { description = "close", group = "client" }),
	awful.key(
		{ modkey, "Control" },
		"space",
		awful.client.floating.toggle,
		{ description = "toggle floating", group = "client" }
	),
	awful.key({ modkey, "Control" }, "Return", function(c)
		c:swap(awful.client.getmaster())
	end, { description = "move to master", group = "client" }),
	awful.key({ modkey }, "o", function(c)
		c:move_to_screen()
	end, { description = "move to screen", group = "client" }),
	awful.key({ modkey }, "t", function(c)
		c.ontop = not c.ontop
	end, { description = "toggle keep on top", group = "client" }),
	awful.key({ modkey }, "n", function(c)
		-- The client currently has the input focus, so it cannot be
		-- minimized, since minimized clients can't have the focus.
		c.minimized = true
	end, { description = "minimize", group = "client" }),
	awful.key({ modkey }, "m", function(c)
		c.maximized = not c.maximized
		c:raise()
	end, { description = "(un)maximize", group = "client" }),
	awful.key({ modkey, "Control" }, "m", function(c)
		c.maximized_vertical = not c.maximized_vertical
		c:raise()
	end, { description = "(un)maximize vertically", group = "client" }),
	awful.key({ modkey, "Shift" }, "m", function(c)
		c.maximized_horizontal = not c.maximized_horizontal
		c:raise()
	end, { description = "(un)maximize horizontally", group = "client" })
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
	globalkeys = gears.table.join(
		globalkeys,
		-- View tag only.
		awful.key({ modkey }, "#" .. i + 9, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				tag:view_only()
			end
		end, { description = "view tag #" .. i, group = "tag" }),
		-- Toggle tag display.
		awful.key({ modkey, "Control" }, "#" .. i + 9, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				awful.tag.viewtoggle(tag)
			end
		end, { description = "toggle tag #" .. i, group = "tag" }),
		-- Move client to tag.
		awful.key({ modkey, "Shift" }, "#" .. i + 9, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:move_to_tag(tag)
				end
			end
		end, { description = "move focused client to tag #" .. i, group = "tag" }),
		-- Toggle tag on focused client.
		awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:toggle_tag(tag)
				end
			end
		end, { description = "toggle focused client on tag #" .. i, group = "tag" })
	)
end

clientbuttons = gears.table.join(
	awful.button({}, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
	end),
	awful.button({ modkey }, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.move(c)
	end),
	awful.button({ modkey }, 3, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.resize(c)
	end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
	-- All clients will match this rule.
	{
		rule = {},
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			raise = true,
			keys = clientkeys,
			buttons = clientbuttons,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap + awful.placement.no_offscreen,
		},
	},

	-- Floating clients.
	{
		rule_any = {
			instance = {
				"DTA", -- Firefox addon DownThemAll.
				"copyq", -- Includes session name in class.
				"pinentry",
			},
			class = {
				"Arandr",
				"Blueman-manager",
				"Gpick",
				"Kruler",
				"MessageWin", -- kalarm.
				"Sxiv",
				"Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
				"Wpa_gui",
				"veromix",
				"xtightvncviewer",
			},

			-- Note that the name property shown in xprop might be set slightly after creation of the client
			-- and the name shown there might not match defined rules here.
			name = {
				"Event Tester", -- xev.
			},
			role = {
				"AlarmWindow", -- Thunderbird's calendar.
				"ConfigManager", -- Thunderbird's about:config.
				"pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
			},
		},
		properties = { floating = true },
	},

	-- Add titlebars to normal clients and dialogs, if in vm_mode
	{ rule_any = { type = { "normal", "dialog" } }, properties = { titlebars_enabled = settings.vm_mode } },

	-- Set Firefox to always map on the tag named "2" on screen 1.
	-- { rule = { class = "Firefox" },
	--   properties = { screen = 1, tag = "2" } },
}

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
	-- }}}
end

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
	-- Set the windows at the slave,
	-- i.e. put it at the end of others instead of setting it master.
	-- if not awesome.startup then awful.client.setslave(c) end

	if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
		-- Prevent clients from being unreachable after screen count changes.
		awful.placement.no_offscreen(c)
	end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
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
client.connect_signal("mouse::enter", function(c)
	c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

client.connect_signal("focus", function(c)
	c.border_color = beautiful.border_focus
end)
client.connect_signal("unfocus", function(c)
	c.border_color = beautiful.border_normal
end)
-- }}}

-- Run applets for system tray.
-- Make sure `nm-tray` is installed. Network manager applet.
awful.spawn.with_shell("pkill nm-tray; nm-tray")
-- Make sure `pasystray` is installed. Pulse audio control.
awful.spawn.with_shell("pkill pasystray; pasystray")
-- Make sure `blueman` is installed. Bluetooth control.
awful.spawn.with_shell("blueman-applet")
-- configure timeout with `xset s <timeout>`
-- Make sure i3lock-color and xss-lock is installed. Automatic locking.
awful.spawn.with_shell("xss-lock -l -- " .. lock_command)
-- Make sure flameshot is installed. Screenshot tool.
awful.spawn.with_shell("flameshot")
-- Make sure dunst is installed. Notification daemon.
-- awful.spawn.with_shell("dunst")
-- Enable touch to tap on touch pad
awful.spawn.with_shell('xinput set-prop "UNIW0001:00 093A:0255 Touchpad" "libinput Tapping Enabled" 1')
-- Enable natural scrolling
awful.spawn.with_shell('xinput set-prop "UNIW0001:00 093A:0255 Touchpad" "libinput Natural Scrolling Enabled" 1')
-- Resize wallpaper using fill, so that it fits the screen
awful.spawn.with_shell("feh --bg-fill " .. beautiful.wallpaper)
-- Enable compositor
if settings.compositor then
	awful.spawn.with_shell("/usr/local/bin/picom --config ~/.config/picom/picom.conf &")
end
