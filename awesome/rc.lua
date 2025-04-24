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
local dpi = require("beautiful.xresources").apply_dpi

local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Widgets
local widgets = require("widgets")

-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
if settings.vim_keys then
	require("awful.hotkeys_popup.keys.vim")
end
-- require("awful.hotkeys_popup.keys")

-- Load Debian menu entries
local debian = require("debian.menu")
local has_fdo, freedesktop = pcall(require, "freedesktop")

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(config_path .. "theme/theme.lua")

-- Configure naughty to center in the top right with some outer padding
naughty.config.defaults.position = "bottom_right"
naughty.config.defaults.margin = 15
naughty.config.padding = dpi(25)
naughty.config.spacing = dpi(10)

-- Configure lock screen and lock screen wallpaper
local lock_screen_fg = beautiful.fg_focus:sub(2)
local lock_screen_hl = beautiful.bg_focus:sub(2)
local lock_screen_bg = beautiful.bg_normal:sub(2)
local lock_screen_wp_path = settings.lock_screen_wallpaper

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
	.. ' --time-str="%H:%M" --date-str="%A, %Y-%m-%d" --wrong-text="Incorrect" --noinput-text="No input"'
	.. ' --verif-text="Verifying..."'
	.. " --custom-key-commands"
	.. ' --cmd-media-play "playerctl play-pause"'
	.. ' --cmd-media-next "playerctl next"'
	.. ' --cmd-media-prev "playerctl previous"'
	.. ' --cmd-volume-up "pactl set-sink-volume @DEFAULT_SINK@ +2%"'
	.. ' --cmd-volume-down "pactl set-sink-volume @DEFAULT_SINK@ -2%"'
	.. ' --cmd-audio-mute "pactl set-sink-mute @DEFAULT_SINK@ toggle"'
	.. ' --cmd-brightness-up "xbacklight -inc 10"'
	.. ' --cmd-brightness-down "xbacklight -dec 10"'

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
	-- If `debian.menu` exists, use it to build the menu
	if debian and debian.menu.Debian_menu then
		mymainmenu = awful.menu({
			items = {
				menu_awesome,
				{ "Debian", debian.menu.Debian_menu.Debian },
				menu_terminal,
			},
		})
	else
		mymainmenu = awful.menu({
			items = {
				menu_awesome,
				menu_terminal,
			},
		})
	end
end

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

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
	s.mylayoutbox = widgets.layoutbox(s)
	-- Create a taglist widget
	s.mytaglist = widgets.taglist(s)
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
			widgets.ramgraph,
			widgets.cpugraph,
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
			powerline_left_secondary(widgets.caffeine),
			powerline_left_primary(widgets.volume),
			powerline_left_secondary(widgets.battery),
			powerline_left_primary(widgets.weather),
			powerline_left_secondary(widgets.clock),
			powerline_left_primary(s.mylayoutbox),
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

	-- Refresh displays
	awful.key({ modkey }, "d", function()
		awful.spawn("/home/jacob/display_fix.sh")
	end, { description = "refresh displays", group = "hotkeys" }),

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
		awful.client.swap.byidx(-1)
	end, { description = "swap with next client by index", group = "client" }),
	awful.key({ modkey, "Shift" }, "k", function()
		awful.client.swap.byidx(1)
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
		awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +2%")
	end, { description = "increase volume", group = "media" }),

	awful.key({}, "XF86AudioLowerVolume", function()
		awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -2%")
	end, { description = "decrease volume", group = "media" }),

	awful.key({}, "XF86AudioMute", function()
		awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")
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
	-- toggle keep on bottom
	awful.key({ modkey, "Shift" }, "t", function(c)
		c.below = not c.below
	end, { description = "toggle keep on bottom", group = "client" }),
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

-- Connect promptbox toggle event
globalkeys = widgets.promptbox(beautiful, globalkeys)

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
	{
		rule_any = { type = { "normal", "dialog" } },
		except = { name = "Wallpaper Pop-out" },
		properties = { titlebars_enabled = settings.vm_mode },
	},

	-- Keep wallpaper engine popout always on the bottom
	{
		rule = { name = "Wallpaper Pop-out" },
		properties = {
			floating = false,
			maximized = true,
			sticky = true,
			below = true,
			skip_taskbar = true,
			focusable = false,
			titlebars_enabled = false,
			border_width = 0,
		},
	},

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
awful.spawn.with_shell("pkill xss-lock; xss-lock -l -- " .. lock_command)
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
-- awful.spawn.with_shell("tuxedo-control-center")
