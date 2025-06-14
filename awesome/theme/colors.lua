local json = require("dkjson")

-- Default style
local style = {
	wallpaper = "theme/wallpaper.jpg",
	primary_color = "#92d7f4", -- bright and colorful
	highlight_color = "#1a5598", -- medium color
	background_color = "#091a34", -- Should be a dark color
	secondary_color = "#d3dae3", -- Should be close to white
}

local wal_file = os.getenv("HOME") .. "/.cache/wal/colors.json"

local file = io.open(wal_file, "r")
if file then
	local contents = file:read("*a")
	file:close()

	local data, pos, err = json.decode(contents, 1, nil)
	if err then
		return style
	end

	style.background_color = data.special.background or style.background_color
	style.secondary_color = data.special.foreground or style.secondary_color
	style.highlight_color = data.colors.color4 or style.highlight_color
	style.primary_color = "#dbdbdb"
	style.wallpaper = data.wallpaper or style.wallpaper
end

return style
