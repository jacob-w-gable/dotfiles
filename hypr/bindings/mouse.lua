-- Mouse bindings. Mirrors awesome/bindings/mouse.lua.

local settings = require("config")

local mod = settings.modkey

return function()
	-- 272 is BTN_LEFT and 273 BTN_RIGHT, the evdev codes behind awesome's button 1
	-- and 3.
	hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
	hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

	-- awesome scrolls through tags on the desktop root window. Wayland has no root
	-- window to click, so this hangs off the modifier instead.
	hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
	hl.bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

	-- Button 3 on the desktop opens awesome's main menu. There is no desktop surface
	-- to bind here; Mod+A opens the launcher, which is the same idea.
end
