-- Theme variants.
--
-- settings.theme selects one. It used to be a bare string compared with == in
-- three places, with anything unrecognised silently falling through to
-- powerline -- so a typo gave you the wrong theme rather than an error.
--
-- This module also breaks a dependency cycle in spirit: the taglist's beautiful
-- keys used to live in widgets/taglist.lua, which meant theme/theme.lua had to
-- require a widget to finish building itself, the reverse of how every other
-- widget relates to the theme. The keys are theme data, so they live here; the
-- widget template stays in the widget and reads `name` from here.

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
