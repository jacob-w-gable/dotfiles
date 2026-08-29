-- Alpha suffixes for theme colours.
--
-- awesome takes colours as #RRGGBB or #RRGGBBAA, so transparency is applied by
-- appending two hex digits. Those digits were written as bare literals in
-- eight places across five files, which made "how see-through is the bar"
-- something you had to grep for.
--
-- Every level here is gated on settings.opacity: with it off, colours come
-- back untouched rather than each call site repeating the check.

local settings = require("config")

-- Named for what they are used for, not for their value.
local LEVELS = {
	popup = "B3", -- notifications, the run prompt
	bar = "D9", -- the wibar and titlebars
	faint = "33", -- taglist fills for occupied and empty tags
	separator = "88", -- the vertical rules between bar sections
}

--- Append the alpha for `level` to `color`, honouring settings.opacity.
return function(color, level)
	local suffix = LEVELS[level]
	assert(suffix, "unknown alpha level: " .. tostring(level))

	if not settings.opacity then
		return color
	end

	return color .. suffix
end
