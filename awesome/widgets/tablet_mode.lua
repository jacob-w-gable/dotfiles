-- Tablet mode: one switch that makes the desktop usable with a finger.
--
-- Turning it on maximises every tag, raises the on-screen keyboard, forces
-- titlebars on (the only touch target for moving or closing a window when
-- there is no keyboard) and adds a finger-sized launcher to the bar.
--
-- Driven three ways: the bar widget, the modkey+Control+t binding, and the
-- tablet::mode signal that scripts/tablet-mode-daemon.py emits when the
-- hardware fold switch flips. See autostart.lua for that wiring.

local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local naughty = require("naughty")
local beautiful = require("beautiful")
local apps = require("config.apps")
local settings = require("config")
local views = require("widgets.views")
local osk = require("widgets.onscreen_keyboard")

-- Only convertibles expose a tablet-mode switch. Everywhere else this module
-- stays inert and its widgets never appear, so sharing this config with a
-- non-convertible machine changes nothing visible.
local function hardware_supported()
	local f = io.open("/proc/bus/input/devices", "r")
	if not f then
		return false
	end
	local contents = f:read("*a")
	f:close()
	return contents:find("Tablet Mode Control switch", 1, true) ~= nil
end

local supported = hardware_supported()

local indicator = views.new()
local launcher = views.new(function(view, visible)
	view.visible = visible
end, false)

local active = false
local saved_layouts = {}

local function markup(text)
	return string.format('<span font="%s">%s</span>', beautiful.font, text)
end

-- Tablet mode needs titlebars even when vm_mode is off. The rules table bakes
-- settings.vm_mode in at load time, so toggle them on clients directly rather
-- than trying to change the setting. Skips the on-screen keyboard and the
-- wallpaper pop-out, which have their own rules deliberately disabling them.
local function wants_titlebar(c)
	if c.class == apps.osk_class or c.name == apps.wallpaper_popout_name then
		return false
	end
	return c.type == "normal" or c.type == "dialog"
end

local function set_titlebars(visible)
	if settings.vm_mode then
		-- Already enabled for every client by the rules; leave them alone.
		return
	end
	for _, c in ipairs(client.get()) do
		if wants_titlebar(c) then
			if visible then
				awful.titlebar.show(c)
			else
				awful.titlebar.hide(c)
			end
		end
	end
end

local function each_tag(fn)
	for s in screen do
		for _, t in ipairs(s.tags) do
			fn(t)
		end
	end
end

--- Enter or leave tablet mode.
local function set(want)
	if not supported or want == active then
		return
	end
	active = want

	if want then
		saved_layouts = {}
		each_tag(function(t)
			saved_layouts[t] = t.layout
			t.layout = awful.layout.suit.max
		end)
		osk.show(false)
		set_titlebars(true)
	else
		each_tag(function(t)
			if saved_layouts[t] then
				t.layout = saved_layouts[t]
			end
		end)
		saved_layouts = {}
		osk.hide(false)
		set_titlebars(false)
		-- Undo any rotation applied while in tablet mode.
		awesome.emit_signal("tablet::orientation", "normal")
	end

	indicator.set(markup(want and "Tablet •" or "Tablet"))
	launcher.set(want)
	naughty.notify({ title = "Tablet Mode", text = want and "Enabled" or "Disabled", timeout = 2 })
end

local function toggle()
	set(not active)
end

-- Clients opened while tablet mode is active missed the titlebar pass above,
-- and the rules already ran with vm_mode's value, so catch them here.
client.connect_signal("manage", function(c)
	if active and not settings.vm_mode and wants_titlebar(c) then
		awful.titlebar.show(c)
	end
end)

-- scripts/tablet-mode-daemon.py runs as a systemd --user service, watching the
-- hardware fold switch and the accelerometer and emitting these two signals
-- through awesome-client. It exits straight away on hardware without the
-- switch, so on a non-convertible neither signal is ever raised.
awesome.connect_signal("tablet::mode", set)

-- Rotation is a shell script rather than done here because keeping the picture
-- and the touch/pen input aligned takes xrandr, xsetwacom and an xinput
-- coordinate transformation matrix together.
awesome.connect_signal("tablet::orientation", function(orientation)
	local script = require("gears.filesystem").get_configuration_dir() .. "scripts/rotate-screen.sh"
	awful.spawn.with_shell(script .. " " .. orientation)
end)

local M = {
	supported = supported,
	set = set,
	toggle = toggle,
}

function M.enable()
	set(true)
end

function M.disable()
	set(false)
end

--- The bar indicator: left-click toggles tablet mode, right-click launches apps.
function M.new()
	local textbox = indicator.add(wibox.widget.textbox(markup(active and "Tablet •" or "Tablet")))

	local widget = wibox.widget({
		textbox,
		widget = wibox.container.margin,
		left = 5,
		right = 1,
	})

	widget:buttons(gears.table.join(
		awful.button({}, 1, toggle),
		awful.button({}, 3, function()
			awful.spawn(apps.launcher)
		end)
	))

	-- Hidden outright on hardware with no fold switch.
	widget.visible = supported

	return widget
end

--- A finger-sized launcher, shown only while tablet mode is active.
--
-- The indicator's right-click opens the same launcher, but a right-click is
-- not something you can do with a finger, so tablet mode needs a plain tap
-- target of its own.
function M.new_launcher()
	local widget = wibox.widget({
		{
			markup = markup("Apps"),
			widget = wibox.widget.textbox,
		},
		widget = wibox.container.margin,
		left = 14,
		right = 14,
	})

	launcher.add(widget)

	return widget
end

return M
