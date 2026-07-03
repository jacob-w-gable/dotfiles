local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")
local theme = require("theme.theme")

local weather_widget = wibox.widget.textbox()
local weather_widget_with_margin = wibox.container.margin(weather_widget, 5, 5, 0, 0)

local lat = nil
local lon = nil
local forecast_url = nil

local function set_text(text)
	weather_widget.markup = string.format('<span font="%s">%s</span>', theme.font, text)
end

local function forecast_to_icon(forecast)
	forecast = forecast:lower()

	if forecast:find("thunder") then
		return "⛈️"
	elseif forecast:find("snow") then
		return "🌨️"
	elseif forecast:find("sleet") then
		return "🌨️"
	elseif forecast:find("rain") then
		return "🌧️"
	elseif forecast:find("shower") then
		return "🌦️"
	elseif forecast:find("fog") then
		return "🌫️"
	elseif forecast:find("mostly cloudy") then
		return "☁️"
	elseif forecast:find("partly cloudy") then
		return "⛅"
	elseif forecast:find("mostly sunny") then
		return "🌤️"
	elseif forecast:find("sunny") then
		return "🌞"
	elseif forecast:find("clear") then
		return "🌞"
	end

	return "❓"
end

local function fetch_coordinates(callback)
	local cmd = [[
curl --silent --show-error --fail \
  --connect-timeout 3 \
  --max-time 10 \
  -A 'AwesomeWM Weather Widget' \
  'https://ipapi.co/json/' |
jq -r '[.latitude, .longitude] | @tsv'
]]

	awful.spawn.easy_async_with_shell(cmd, function(stdout, stderr, _, exit_code)
		if exit_code ~= 0 then
			callback(false)
			return
		end

		local new_lat, new_lon = stdout:match("^%s*([^%s]+)%s+([^%s]+)")

		if not new_lat then
			callback(false)
			return
		end

		lat = new_lat
		lon = new_lon

		callback(true)
	end)
end

local function fetch_forecast_url(callback)
	local cmd = string.format(
		[[
curl --silent --show-error --fail \
  --connect-timeout 3 \
  --max-time 10 \
  -H 'User-Agent: AwesomeWM Weather Widget' \
  'https://api.weather.gov/points/%s,%s' |
jq -r '.properties.forecastHourly'
]],
		lat,
		lon
	)

	awful.spawn.easy_async_with_shell(cmd, function(stdout, stderr, _, exit_code)
		if exit_code ~= 0 then
			callback(false)
			return
		end

		stdout = stdout:gsub("%s+$", "")

		if stdout == "" or stdout == "null" then
			callback(false)
			return
		end

		forecast_url = stdout
		callback(true)
	end)
end

local function fetch_weather()
	local cmd = string.format(
		[[
curl --silent --show-error --fail \
  --connect-timeout 3 \
  --max-time 10 \
  -H 'User-Agent: AwesomeWM Weather Widget' \
  '%s' |
jq -r '.properties.periods[0] | [.temperature, .shortForecast] | @tsv'
]],
		forecast_url
	)

	awful.spawn.easy_async_with_shell(cmd, function(stdout, stderr, _, exit_code)
		if exit_code ~= 0 then
			set_text("--°F")
			return
		end

		stdout = stdout:gsub("%s+$", "")

		local temp, forecast = stdout:match("^([^\t]+)\t(.+)$")

		temp = tonumber(temp)

		if not temp or not forecast then
			set_text("--°F")
			return
		end

		local icon = forecast_to_icon(forecast)
		set_text(string.format("%s %d°F", icon, temp))
	end)
end

local function update_weather()
	if forecast_url then
		fetch_weather()
		return
	end

	if lat and lon then
		fetch_forecast_url(function(success)
			if success then
				fetch_weather()
			else
				set_text("--°F")
			end
		end)
		return
	end

	fetch_coordinates(function(success)
		if not success then
			set_text("--°F")
			return
		end

		fetch_forecast_url(function(success2)
			if success2 then
				fetch_weather()
			else
				set_text("--°F")
			end
		end)
	end)
end

-- Initial fetch
update_weather()

-- Refresh weather every 10 minutes
gears.timer({
	timeout = 600,
	autostart = true,
	call_now = false,
	callback = update_weather,
})

-- Refresh location every 12 hours
gears.timer({
	timeout = 43200,
	autostart = true,
	call_now = false,
	callback = function()
		lat = nil
		lon = nil
		forecast_url = nil
		update_weather()
	end,
})

return weather_widget_with_margin
