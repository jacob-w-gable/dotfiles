-- Theme variants.
--
-- settings.theme selects one, and an unrecognised name is an error rather than
-- a silent fallback.
--
-- The taglist's beautiful keys live here because they are theme data. Keeping
-- them in the widget would mean theme/theme.lua has to require a widget to
-- finish building itself, the reverse of how every other widget reads the
-- theme. The widget template stays in the widget and reads `name` from here.

local gears = require("gears")
local colors = require("theme.colors")
local alpha = require("theme.alpha")
local settings = require("config")

local SQUIRCLE = "squircle"
local POWERLINE = "powerline"

local KNOWN = {
	[SQUIRCLE] = true,
	[POWERLINE] = true,
}

local name = settings.theme
assert(
	KNOWN[name],
	string.format("unknown theme variant %q (expected %q or %q)", tostring(name), SQUIRCLE, POWERLINE)
)

local M = {
	name = name,
	squircle = SQUIRCLE,
	powerline = POWERLINE,
}

--- True when the selected variant is the squircle one.
function M.is_squircle()
	return name == SQUIRCLE
end

--- Add this variant's taglist keys to a beautiful theme table.
--
-- Called during theme construction, so it reads theme.colors directly rather
-- than beautiful, which does not exist yet.
function M.apply_taglist(style)
	if name == SQUIRCLE then
		style.taglist_bg_occupied = alpha(colors.highlight_color, "faint")
		style.taglist_bg_empty = alpha(colors.highlight_color, "faint")
		style.taglist_fg_focus = colors.background_color
		style.taglist_shape = function(cr, w, h)
			gears.shape.rounded_rect(cr, w, h, 6)
		end
		style.taglist_spacing = 6
		return style
	end

	style.taglist_shape = gears.shape.powerline
	style.taglist_spacing = -12
	return style
end

return M
