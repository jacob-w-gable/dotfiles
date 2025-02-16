local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local settings = require("settings")

local function build_promptbox(beautiful)
	local prompt_popup_bg = beautiful.bg_normal
	local prompt_popup_border = beautiful.border_focus
	if settings.opacity then
		prompt_popup_bg = prompt_popup_bg .. "B3"
		prompt_popup_border = prompt_popup_border .. "B3"
	end

	-- Create a floating popup wibox
	local prompt_popup = wibox({
		width = 500, -- Adjust width as needed
		height = 60, -- Adjust height as needed
		ontop = true,
		visible = false,
		bg = prompt_popup_bg,
		border_color = prompt_popup_border,
		border_width = beautiful.border_width,
		shape = function(cr, width, height)
			gears.shape.rounded_rect(cr, width, height, 20) -- Rounded corners
		end,
	})

	-- Create the prompt widget
	local promptbox = awful.widget.prompt()

	-- Add the promptbox to the wibox
	prompt_popup:setup({
		{
			promptbox,
			widget = wibox.container.margin,
			margins = 10,
		},
		layout = wibox.layout.fixed.horizontal,
	})

	-- Function to show the prompt at the center of the screen
	local function show_prompt()
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
				prompt_popup.visible = false -- Hide after command
			end,
			history_path = awful.util.get_cache_dir() .. "/history_run",
			done_callback = function()
				prompt_popup.visible = false
			end, -- Hide when dismissed
		})
	end

	-- Return keys to show the prompt
	return gears.table.join(
		globalkeys,
		awful.key({ modkey }, "r", show_prompt, { description = "run prompt", group = "launcher" })
	)
end

return build_promptbox
