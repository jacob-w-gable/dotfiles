-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local awful = require("awful")
require("awful.autofocus")

-- Personal settings, merged with any per-machine overrides. Requiring this
-- also pins the UI scale -- see config/init.lua.
local settings = require("config")
local solo = require("solo")

-- Theme handling library
local beautiful = require("beautiful")

-- Widgets
local widgets = require("widgets")


-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
if settings.vim_keys then
	require("awful.hotkeys_popup.keys.vim")
end
-- require("awful.hotkeys_popup.keys")

-- Themes define colours, icons, font and wallpapers.
-- Pass the theme table, not a path: beautiful.init uses dofile() for a
-- string, which bypasses package.loaded and builds a second, separate
-- theme table from the one the widgets already required.
beautiful.init(require("theme.theme"))

require("config.layouts")
require("ui.errors")
require("ui.notifications")
require("ui.wallpaper")

local mymainmenu = require("ui.menu")

-- Define pomodoro widget globally, since we need hotkeys to control it
local pomo = widgets.pomodoro.new({
	work_minutes = 25,
	short_break_minutes = 5,
	long_break_minutes = 5,
	long_break_every = 17,
	auto_advance = true,
	show_progress = false,
	notify = true,
	sound = {
		enabled = true,
		on_finish = os.getenv("HOME") .. "/.config/awesome/theme/alarm1.wav",
		-- on_start = os.getenv("HOME") .. "/.config/awesome/sounds/chime.mp3",
		player = "paplay",
	},
})

require("ui.bar")({ pomodoro = pomo })

local mouse_bindings = require("bindings.mouse")
local clientkeys = require("bindings.client")()
local clientbuttons = mouse_bindings.client()

mouse_bindings.root(mymainmenu)
root.keys(require("bindings.global")({ menu = mymainmenu, pomodoro = pomo }))

awful.rules.rules = require("rules")(clientkeys, clientbuttons)

require("ui.titlebar")
solo.connect()

require("signals")
require("autostart")
