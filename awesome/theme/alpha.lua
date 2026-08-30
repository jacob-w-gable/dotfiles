-- Alpha suffixes for theme colours.
--
-- awesome takes colours as #RRGGBB or #RRGGBBAA, so transparency means
-- appending two hex digits. Naming the levels keeps "how see-through is the
-- bar" in one place.
--
-- Levels come in two kinds. Some are transparency the user opted into with
-- settings.opacity, and are skipped when it is off. Others are visual weight
-- (a faint tag fill, a subtle divider) and apply either way. Conflating the
-- two makes every tag look selected when opacity is off, because the faint
-- fill becomes the same solid colour as the focused one.

local settings = require("config")

-- Named for what they are used for, not for their value. `optional` marks the
-- levels that settings.opacity turns off.
local LEVELS = {
	popup = { suffix = "B3", optional = true }, -- notifications, the run prompt
	bar = { suffix = "D9", optional = true }, -- the wibar and titlebars
	faint = { suffix = "33" }, -- taglist fills for occupied and empty tags
	separator = { suffix = "88" }, -- the vertical rules between bar sections
}

--- Append the alpha for `level` to `color`.
return function(color, level)
	local spec = LEVELS[level]
	assert(spec, "unknown alpha level: " .. tostring(level))

	if spec.optional and not settings.opacity then
		return color
	end

	return color .. spec.suffix
end
