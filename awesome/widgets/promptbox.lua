local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local settings = require("settings")

-- A centered run prompt in its own floating popup, separate from the
-- awful.widget.prompt that lives in the wibar.
--
-- Built lazily: beautiful.init has not necessarily run by the time this module
-- is required, so the popup is constructed on first use rather than at load.
local prompt_popup, promptbox

local function build()
	local popup_bg = beautiful.bg_normal
	local popup_border = beautiful.border_focus
	if settings.opacity then
		popup_bg = popup_bg .. "B3"
		popup_border = popup_border .. "B3"
	end

	prompt_popup = wibox({
		width = 500,
		height = 60,
		ontop = true,
		visible = false,
		bg = popup_bg,
		border_color = popup_border,
		border_width = beautiful.border_width,
		shape = function(cr, width, height)
			gears.shape.rounded_rect(cr, width, height, 20)
		end,
	})

	promptbox = awful.widget.prompt()

	prompt_popup:setup({
		{
			promptbox,
			widget = wibox.container.margin,
			margins = 10,
		},
		layout = wibox.layout.fixed.horizontal,
	})
end

local M = {}

--- Show the run prompt, centered on the focused screen.
function M.show()
	if not prompt_popup then
		build()
	end

	local screen_geo = awful.screen.focused().geometry
	prompt_popup.x = screen_geo.x + (screen_geo.width - prompt_popup.width) / 2
	prompt_popup.y = screen_geo.y + (screen_geo.height - prompt_popup.height) / 3
	prompt_popup.visible = true

	awful.prompt.run({
		prompt = "Run: ",
		textbox = promptbox.widget,
		exe_callback = function(cmd)
			if cmd and cmd ~= "" then
				awful.spawn(cmd)
			end
			prompt_popup.visible = false
		end,
		history_path = awful.util.get_cache_dir() .. "/history_run",
		done_callback = function()
			prompt_popup.visible = false
		end,
	})
end

return M
