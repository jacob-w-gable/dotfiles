-- Global key bindings, including the per-tag number keys.

local awful = require("awful")
local gears = require("gears")
local hotkeys_popup = require("awful.hotkeys_popup")

local settings = require("config")
local apps = require("config.apps")
local solo = require("solo")

local modkey = settings.modkey
local terminal = apps.terminal

return function(args)
	local mymainmenu = args.menu
	local pomo = args.pomodoro

	-- Toggled by Mod+e below. Module state, so it resets on restart while a
	-- running redshift survives -- see the note in the plan.
	local redshift_enabled = false

	local globalkeys = gears.table.join(
		awful.key({ modkey }, "s", hotkeys_popup.show_help, { description = "show help", group = "awesome" }),
		awful.key({ modkey }, "Left", awful.tag.viewprev, { description = "view previous", group = "tag" }),
		awful.key({ modkey }, "Right", awful.tag.viewnext, { description = "view next", group = "tag" }),
		awful.key({ modkey }, "Escape", awful.tag.history.restore, { description = "go back", group = "tag" }),

		-- Personal hotkeys
		awful.key({ modkey }, "d", function()
			if settings.display_fix_command then
				awful.spawn(settings.display_fix_command)
			end
		end, { description = "refresh displays", group = "hotkeys" }),
		awful.key({ modkey }, "w", function()
			-- Config-relative, so it follows the ~/.config/awesome symlink rather
			-- than assuming the repo is checked out at ~/dotfiles.
			awful.spawn.with_shell(require("gears.filesystem").get_configuration_dir() .. "theme/wallpaper")
		end, { description = "change wallpaper", group = "hotkeys" }),
		awful.key({ modkey }, "c", function()
			require("widgets.caffeine").toggle()
		end, { description = "toggle caffeine", group = "hotkeys" }),
		awful.key({ modkey }, "e", function()
			redshift_enabled = not redshift_enabled
			if not redshift_enabled then
				awful.spawn("redshift -x")
				return
			end
			awful.spawn("redshift -O 3500")
		end, { description = "toggle eye saver mode", group = "hotkeys" }),
		awful.key({ modkey, "Shift" }, "p", function()
			pomo.toggle_visible()
		end, {
			description = "Toggle pomodoro widget",
			group = "hotkeys",
		}),

		awful.key({ modkey }, "j", function()
			solo.focus_next(-1)
		end, { description = "focus next by index", group = "client" }),
		awful.key({ modkey }, "k", function()
			solo.focus_next(1)
		end, { description = "focus previous by index", group = "client" }),
		awful.key({ modkey }, "a", function()
			mymainmenu:show()
		end, { description = "show main menu", group = "awesome" }),

		-- Layout manipulation
		awful.key({ modkey, "Shift" }, "j", function()
			awful.client.swap.byidx(-1)
		end, { description = "swap with next client by index", group = "client" }),
		awful.key({ modkey, "Shift" }, "k", function()
			awful.client.swap.byidx(1)
		end, { description = "swap with previous client by index", group = "client" }),
		awful.key({ modkey, "Mod1" }, "j", function()
			awful.screen.focus_relative(1)
		end, { description = "focus the next screen", group = "screen" }),
		awful.key({ modkey, "Mod1" }, "k", function()
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
		awful.key({ modkey }, "r", awesome.restart, { description = "reload awesome", group = "awesome" }),
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

		awful.key({ modkey, "Shift" }, "n", function()
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
		awful.key({ modkey }, "p", function()
			awful.spawn("rofi -show drun")
		end, { description = "application launcher", group = "launcher" }),
		awful.key({ modkey, "Control" }, "r", require("widgets.promptbox").show, {
			description = "run prompt",
			group = "launcher",
		}),
		-- Screenshot
		awful.key({ modkey, "Shift" }, "s", function()
			awful.spawn("flameshot gui")
		end, {
			description = "take screenshot with flameshot",
			group = "launcher",
		}),

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
			awful.spawn.with_shell(apps.brightness_up)
		end, { description = "increase brightness", group = "media" }),

		awful.key({}, "XF86MonBrightnessDown", function()
			awful.spawn.with_shell(apps.brightness_down)
		end, { description = "decrease brightness", group = "media" }),

		awful.key({ "Mod4" }, "'", function()
			awful.spawn("xset s activate")
		end, { description = "lock screen", group = "hotkeys" })
	)

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

	return globalkeys
end
