-- Palette, read from pywal's cache with the same fallbacks the AwesomeWM theme uses.
--
-- awesome/theme/colors.lua parses ~/.cache/wal/colors.json with dkjson. There is no
-- JSON parser in the Lua that Hyprland embeds, and adding one to load six colours would
-- be silly, so pywal writes a Lua table directly instead - see wal/templates. That also
-- means a truncated file is a load error this can catch, rather than a nil index.

-- The default wallpaper is awesome's, reached through a symlink in this directory
-- rather than through ~/.config/awesome: the two configs share the image, but this one
-- should not stop working because the other is not installed. The link is relative, so
-- it resolves inside the repo wherever ~/.config/hypr points.
local style = {
	primary_color = "#dbdbdb",
	highlight_color = "#1a5598",
	background_color = "#091a34",
	secondary_color = "#d3dae3",
	wallpaper = os.getenv("HOME") .. "/.config/hypr/theme/wallpaper.jpg",
}

local cache = os.getenv("HOME") .. "/.cache/wal/colors-hyprland.lua"

local ok, wal = pcall(dofile, cache)
if ok and type(wal) == "table" then
	style.background_color = wal.background or style.background_color
	style.secondary_color = wal.foreground or style.secondary_color
	style.highlight_color = wal.color4 or style.highlight_color
	style.wallpaper = wal.wallpaper or style.wallpaper
	-- Deliberately not taken from pywal, matching awesome: the generated foreground is
	-- often too close to the background to read as a border.
	style.primary_color = "#dbdbdb"
end

return style
