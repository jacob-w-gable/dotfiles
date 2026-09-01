-- Rules applied to new clients, via the "manage" signal.
--
-- Returns the table, so rc.lua decides when it takes effect and passes in the
-- client keys and buttons.

local awful = require("awful")
local beautiful = require("beautiful")
local apps = require("config.apps")
local settings = require("config")

return function(keys, buttons)
	-- Rules to apply to new clients (through the "manage" signal).
	return {
		-- All clients will match this rule.
		{
			rule = {},
			properties = {
				floating = false,
				border_width = beautiful.border_width,
				border_color = beautiful.border_normal,
				focus = awful.client.focus.filter,
				raise = true,
				keys = keys,
				buttons = buttons,
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
			except = { name = apps.wallpaper_popout_name },
			properties = { titlebars_enabled = settings.vm_mode },
		},

		-- Keep wallpaper engine popout always on the bottom
		{
			rule = { name = apps.wallpaper_popout_name },
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

		-- On-screen keyboard: floats on top without taking focus. Tablet mode
		-- puts every tag in the max layout, which would otherwise tile the
		-- keyboard fullscreen, and focusable = false keeps typing going to the
		-- window underneath instead of to the keyboard itself.
		{
			rule_any = {
				class = { apps.osk_class },
				instance = { "onboard" },
			},
			properties = {
				floating = true,
				ontop = true,
				sticky = true,
				focusable = false,
				skip_taskbar = true,
				titlebars_enabled = false,
				border_width = 0,
				-- Onboard docks itself to the bottom edge, so only keep it on
				-- screen; the default no_overlap would shove it out of the way of
				-- other windows.
				placement = awful.placement.no_offscreen,
			},
		},

		-- Set Firefox to always map on the tag named "2" on screen 1.
		-- { rule = { class = "Firefox" },
		--   properties = { screen = 1, tag = "2" } },
	}
end
