local wibox = require("wibox")
local gears = require("gears")
local theme = require("theme.theme")

local weather_widget = wibox.widget.textbox()
local weather_widget_with_margin = wibox.container.margin(weather_widget, 5, 5, 0, 0)

local lat = nil
local lon = nil

local function set_text(text)
	weather_widget.markup = string.format('<span font="%s">%s</span>', theme.font, text)
end

local function fetch_coordinates()
	local cmd = [[
		curl -fsSL -A 'awesomewm' 'https://ipapi.co/json/' 2>/dev/null \
		| jq -r '[.latitude, .longitude, .city, .region_code] | @tsv'
	]]

	local f = io.popen(cmd)
	local output = f and f:read("*a") or ""
	if f then
		f:close()
	end

	output = output:gsub("%s+$", "")
	if output == "" then
		return false
	end

	local new_lat, new_lon = output:match("([^\t]+)\t([^\t]+)\t([^\t]*)\t([^\t]*)")
	if not new_lat or not new_lon then
		return false
	end

	lat = new_lat
	lon = new_lon

	return true
end

local function code_to_icon(code)
	if code == 0 then
		return "☀"
	elseif code == 1 or code == 2 then
		return "⛅"
	elseif code == 3 then
		return "☁"
	elseif code == 45 or code == 48 then
		return "🌫"
	elseif
		code == 51
		or code == 53
		or code == 55
		or code == 56
		or code == 57
		or code == 61
		or code == 63
		or code == 65
		or code == 66
		or code == 67
		or code == 80
		or code == 81
		or code == 82
	then
		return "🌧"
	elseif code == 71 or code == 73 or code == 75 or code == 77 or code == 85 or code == 86 then
		return "❄"
	elseif code == 95 or code == 96 or code == 99 then
		return "⛈"
	end

	return "?"
end

local function update_weather()
	if not lat or not lon then
		if not fetch_coordinates() then
			set_text("--°F")
			return
		end
	end

	local cmd = string.format(
		[[
		curl -fsSL -A 'awesomewm' \
		'https://api.open-meteo.com/v1/forecast?latitude=%s&longitude=%s&current=temperature_2m,weather_code&temperature_unit=fahrenheit' \
		2>/dev/null \
		| jq -r '[.current.temperature_2m, .current.weather_code] | @tsv'
	]],
		lat,
		lon
	)

	local f = io.popen(cmd)
	local output = f and f:read("*a") or ""
	if f then
		f:close()
	end

	output = output:gsub("%s+$", "")
	if output == "" then
		set_text("--°F")
		return
	end

	local temp, code = output:match("([^\t]+)\t([^\t]+)")
	temp = tonumber(temp)
	code = tonumber(code)

	if not temp then
		set_text("--°F")
		return
	end

	local icon = code and code_to_icon(code) or "?"
	local rounded = math.floor(temp + 0.5)

	set_text(string.format("%s %d°F", icon, rounded))
end

-- initial fetch at startup
update_weather()

-- refresh weather every 10 min
gears.timer({
	timeout = 600,
	autostart = true,
	call_now = false,
	callback = update_weather,
})

-- refresh coordinates every 6 hours in case your public IP/location changes
gears.timer({
	timeout = 21600,
	autostart = true,
	call_now = false,
	callback = function()
		fetch_coordinates()
		update_weather()
	end,
})

return weather_widget_with_margin
