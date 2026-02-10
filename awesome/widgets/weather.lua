local wibox = require("wibox")
local gears = require("gears")
local theme = require("theme.theme")

local weather_widget = wibox.widget.textbox()
local weather_widget_with_margin = wibox.container.margin(weather_widget, 5, 5, 0, 0)

local function update()
	local cmd = [[
    curl -fsSL -A 'awesomewm' \
      'https://api.weather.gov/stations/KHSV/observations/latest' 2>/dev/null
  ]]
	local f = io.popen(cmd)
	local json = f and f:read("*a") or ""
	if f then
		f:close()
	end

	-- extract Fahrenheit temperature
	local tempf = json:match([["temperature"%s*:%s*{.-"value"%s*:%s*([%-%d%.]+)]])
	if tempf then
		tempf = tonumber(tempf)
		-- API returns Celsius; convert
		tempf = math.floor((tempf * 9 / 5 + 32) + 0.5)
		weather_widget.markup = string.format('<span font="%s">%d°F (KHSV)</span>', theme.font, tempf)
		return
	end

	weather_widget.markup = string.format('<span font="%s">--°F (KHSV)</span>', theme.font)
end

-- initial + periodic refresh
update()
gears.timer({
	timeout = 600,
	autostart = true,
	call_now = false,
	callback = update,
})

return weather_widget_with_margin
