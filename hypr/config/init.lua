-- Configuration entry point.
--
-- Returns the tracked defaults from config/settings.lua with any per-machine overrides
-- from config/machine.lua layered on top. machine.lua is gitignored, so a touchpad name
-- or a second monitor lives there rather than dirtying the tracked config.
--
-- Mirrors awesome/config/init.lua, minus the DPI pinning: that exists to work around an
-- X server behaviour Wayland does not have.

local settings = require("config.settings")

local ok, machine = pcall(require, "config.machine")
if ok and type(machine) == "table" then
	for key, value in pairs(machine) do
		settings[key] = value
	end
end

assert(type(settings.modkey) == "string", "settings.modkey must be a string")
assert(type(settings.scale) == "number", "settings.scale must be a number")
assert(settings.scale > 0, "settings.scale must be positive")

return settings
