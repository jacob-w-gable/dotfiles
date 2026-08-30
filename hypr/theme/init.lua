-- Derived theme values: the colours in theme/colors.lua turned into the forms Hyprland
-- wants, plus the handful of shades awesome/theme/theme.lua computes rather than states.

local colors = require("theme.colors")
local settings = require("config")

local M = {}

--- Lighten a #rrggbb colour by a fraction, clamping each channel.
-- awesome/theme/theme.lua does the same to derive fg_normal from the highlight colour.
local function brighten(color, amount)
	local r = math.min(255, math.floor(tonumber(color:sub(2, 3), 16) * (1 + amount)))
	local g = math.min(255, math.floor(tonumber(color:sub(4, 5), 16) * (1 + amount)))
	local b = math.min(255, math.floor(tonumber(color:sub(6, 7), 16) * (1 + amount)))
	return string.format("#%02X%02X%02X", r, g, b)
end

--- Convert #rrggbb to the rgba(rrggbbaa) literal Hyprland expects.
-- alpha is 0..1; opacity = false in settings forces everything opaque, as it does in
-- awesome/theme/alpha.lua.
local function rgba(color, alpha)
	if not settings.opacity then
		alpha = 1
	end
	return string.format("rgba(%s%02x)", color:sub(2), math.floor(alpha * 255 + 0.5))
end

M.background = colors.background_color
M.foreground = brighten(colors.highlight_color, 0.4)
M.highlight = colors.highlight_color
M.primary = colors.primary_color
M.secondary = colors.secondary_color

M.border_active = rgba(colors.highlight_color, 1)
M.border_inactive = rgba(colors.background_color, 1)

M.rgba = rgba
M.brighten = brighten

return M
