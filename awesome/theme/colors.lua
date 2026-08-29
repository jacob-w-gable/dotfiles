local config_path = require("gears.filesystem").get_configuration_dir()

-- Find dkjson under whichever Lua version awesome was built against. This was
-- hardcoded to 5.4, which is wrong wherever awesome links 5.3 -- and if the
-- require fails the theme has to keep working, since this runs before the
-- error handler is installed.
local lua_version = _VERSION:match("%d+%.%d+")
package.path = table.concat({
	package.path,
	os.getenv("HOME") .. "/.luarocks/share/lua/" .. lua_version .. "/?.lua",
	os.getenv("HOME") .. "/.luarocks/share/lua/" .. lua_version .. "/?/init.lua",
}, ";")

local ok, json = pcall(require, "dkjson")

-- Default style
local style = {
	wallpaper = config_path .. "theme/wallpaper.jpg",
	primary_color = "#92d7f4", -- bright and colorful
	highlight_color = "#1a5598", -- medium color
	background_color = "#091a34", -- Should be a dark color
	secondary_color = "#d3dae3", -- Should be close to white
}

local wal_file = os.getenv("HOME") .. "/.cache/wal/colors.json"

local file = ok and io.open(wal_file, "r")
if file then
	local contents = file:read("*a")
	file:close()

	local data, pos, err = json.decode(contents, 1, nil)
	if err then
		return style
	end

	-- A truncated or half-written colors.json would otherwise index nil here
	-- and take the whole theme down.
	if type(data) ~= "table" or type(data.special) ~= "table" or type(data.colors) ~= "table" then
		return style
	end

	style.background_color = data.special.background or style.background_color
	style.secondary_color = data.special.foreground or style.secondary_color
	style.highlight_color = data.colors.color4 or style.highlight_color
	style.primary_color = "#dbdbdb"
	style.wallpaper = data.wallpaper or style.wallpaper
end

return style
