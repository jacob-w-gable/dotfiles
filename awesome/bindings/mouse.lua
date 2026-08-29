-- Mouse bindings: the desktop root, and per-client.

local awful = require("awful")
local gears = require("gears")
local settings = require("config")

local modkey = settings.modkey

local M = {}

--- Buttons bound on the desktop root window.
function M.root(mymainmenu)
	root.buttons(gears.table.join(
		awful.button({}, 3, function()
			mymainmenu:toggle()
		end),
		awful.button({}, 4, awful.tag.viewnext),
		awful.button({}, 5, awful.tag.viewprev)
	))

end

--- Buttons bound on each client.
function M.client()
	local clientbuttons = gears.table.join(
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

	return clientbuttons
end

return M
