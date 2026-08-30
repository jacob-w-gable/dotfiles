-- Configuration entry point.
--
-- Returns the merged settings table: tracked defaults from config/settings.lua,
-- with any per-machine overrides from config/machine.lua layered on top.
-- machine.lua is gitignored, so anything that is true of one computer and not
-- the others - a touchpad device name, an extra program to autostart, a
-- different DPI - lives there instead of dirtying the tracked config.
--
-- Requiring this module also pins the UI scale, because that has to happen
-- before the theme or any widget reads a DPI-scaled value.

-- Loaded for the side effect of installing the screen.dpi property, which the
-- pinning below sets. Requiring it here rather than relying on rc.lua's own
-- require means this module is correct whatever order it is pulled in.
require("awful")

local gears = require("gears")
local xresources = require("beautiful.xresources")

local settings = require("config.settings")

local ok, machine = pcall(require, "config.machine")
if ok and type(machine) == "table" then
	settings = gears.table.crush(settings, machine)
end

-- Pin the UI scale. Left alone, awesome takes its DPI from the X server, which
-- derives it from EDID at server startup - so the value depends on which
-- display is awake at boot and the whole UI resizes between reboots.
--
-- Both halves are required and neither implies the other: the global value
-- feeds beautiful.xresources.apply_dpi (borders, gaps, menu sizes), while text
-- is laid out by pango at the *per-screen* DPI.
assert(type(settings.dpi) == "number", "settings.dpi must be a number")
assert(settings.dpi > 0, "settings.dpi must be positive")
xresources.set_dpi(settings.dpi)

local function pin_screen_dpi(s)
	s.dpi = settings.dpi
end

for s in screen do
	pin_screen_dpi(s)
end
screen.connect_signal("added", pin_screen_dpi)

return settings
