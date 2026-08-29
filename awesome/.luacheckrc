-- luacheck configuration for the AwesomeWM config.
--
-- The point of linting here is not style -- stylua handles that -- but catching
-- reads of globals that were never defined. That is the failure mode this
-- config is most prone to: a module reaching for a name that happens to be a
-- global in rc.lua works until the name is made local, then breaks silently at
-- runtime with no load-time error. `awesome -k` cannot see it; luacheck can.

std = "lua53"

-- Globals awesome injects into the config environment. Declared read/write
-- because the API mutates fields on most of them (client.focus, screen.dpi,
-- root.keys, ...).
globals = {
	"awesome",
	"button",
	"client",
	"dbus",
	"drawin",
	"keygrabber",
	"mouse",
	"mousegrabber",
	"root",
	"screen",
	"selection",
	"tag",
	"timer",
}

-- Vendored upstream libraries, cloned in by the installer and gitignored.
exclude_files = {
	"lain/",
	"vicious/",
}

files["rc.lua"] = {
	-- Globals the stock rc.lua defines and the rest of the config reads. They
	-- are declared here so the genuinely broken reads elsewhere stand out
	-- instead of drowning in ~50 legitimate uses of `modkey`.
	--
	-- This list should shrink to nothing: each name that moves into a module
	-- and gets passed explicitly comes out of here. When the table is empty,
	-- delete it.
	globals = {
		"clientbuttons",
		"clientkeys",
		"editor",
		"editor_cmd",
		"globalkeys",
		"modkey",
		"mymainmenu",
		"myawesomemenu",
		"terminal",
	},
}
