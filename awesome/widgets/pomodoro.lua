-- ~/.config/awesome/widgets/pomodoro.lua
local gears = require("gears")
local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")

local pomodoro = {}

local function fmt_mmss(sec)
	if sec < 0 then
		sec = 0
	end
	local m = math.floor(sec / 60)
	local s = sec % 60
	return string.format("%02d:%02d", m, s)
end

local function shell_escape(s)
	-- minimal single-quote escaping for shell strings
	return "'" .. tostring(s):gsub("'", [['"'"']]) .. "'"
end

-- opts:
--   work_minutes (default 25)
--   short_break_minutes (default 5)
--   long_break_minutes (default 15)
--   long_break_every (default 4)
--   show_progress (default true)
--   notify (default true)
--   auto_advance (default true)
--   font (default nil)
--   colors = { work="#...", break="#...", paused="#...", text="#..." }
--
--   sound = {
--     enabled = true,                 -- default true if any file is provided; otherwise false
--     on_finish = "/path/to.wav",     -- played when a phase completes
--     on_start  = nil,               -- optional sound when a phase begins
--     player    = nil,               -- optional override command
--     volume    = nil,               -- optional, only used with some players
--   }
--
-- Notes:
-- - Default player autodetects: paplay -> aplay -> ffplay -> mpg123
-- - For best compatibility: use .wav with paplay/aplay
function pomodoro.new(opts)
	opts = opts or {}

	local work_s = (opts.work_minutes or 25) * 60
	local short_s = (opts.short_break_minutes or 5) * 60
	local long_s = (opts.long_break_minutes or 15) * 60
	local every_n = (opts.long_break_every or 4)
	local do_notify = (opts.notify ~= false)
	local show_progress = (opts.show_progress ~= false)
	local auto_advance = (opts.auto_advance ~= false)

	local colors = opts.colors or {}
	local c_work = colors.work or "#7aa2f7"
	local c_break = colors["break"] or "#9ece6a"
	local c_paused = colors.paused or "#e0af68"

	local snd = opts.sound or {}
	local sound_finish = snd.on_finish
	local sound_start = snd.on_start
	local sound_enabled = (snd.enabled == true) or (snd.enabled == nil and (sound_finish ~= nil or sound_start ~= nil))

	-- If you want to hardcode a player, set opts.sound.player.
	-- Otherwise we pick the first available.
	local function play_sound(path)
		if not sound_enabled then
			return
		end
		if not path or path == "" then
			return
		end

		local p = tostring(path)
		local player = snd.player

		-- Autodetect a player if not provided.
		-- paplay: PulseAudio/PipeWire; aplay: ALSA; ffplay: ffmpeg; mpg123: mp3 only
		local cmd
		if player and player ~= "" then
			cmd = player .. " " .. shell_escape(p)
		else
			cmd = "command -v paplay >/dev/null 2>&1 && paplay "
				.. shell_escape(p)
				.. " || command -v aplay >/dev/null 2>&1 && aplay -q "
				.. shell_escape(p)
				.. " || command -v ffplay >/dev/null 2>&1 && ffplay -nodisp -autoexit -loglevel quiet "
				.. shell_escape(p)
				.. " || command -v mpg123 >/dev/null 2>&1 && mpg123 -q "
				.. shell_escape(p)
				.. " || true"
		end

		awful.spawn.with_shell(cmd)
	end

	local state = {
		phase = "idle", -- "work" | "break" | "idle"
		break_kind = nil, -- "short" | "long"
		running = false,
		remaining = 0,
		total = 0,
		sessions_done = 0, -- completed work sessions
		pending_transition = false,
	}

	local icon = wibox.widget({ widget = wibox.widget.textbox, text = "󰄉 " })
	local label = wibox.widget({ widget = wibox.widget.textbox, text = "Pomo" })
	local timebox = wibox.widget({ widget = wibox.widget.textbox, text = "00:00" })

	if opts.font then
		icon.font = opts.font
		label.font = opts.font
		timebox.font = opts.font
	end

	local bar = wibox.widget({
		widget = wibox.widget.progressbar,
		max_value = 1,
		value = 0,
		forced_width = 60,
		forced_height = 8,
		paddings = 1,
		border_width = 0,
		color = c_work,
		background_color = "#00000000",
	})

	local container = wibox.widget({
		layout = wibox.layout.fixed.horizontal,
		spacing = 8,
		icon,
		label,
		timebox,
	})
	if show_progress then
		container:add(bar)
	end

	local function notify(title, text)
		if not do_notify then
			return
		end
		naughty.notify({ title = title, text = text, timeout = 5 })
	end

	local function current_work_index()
		return (state.sessions_done % every_n) + 1
	end

	local function set_color()
		if not show_progress then
			return
		end
		if state.phase == "work" then
			bar.color = state.running and c_work or c_paused
		elseif state.phase == "break" then
			bar.color = state.running and c_break or c_paused
		else
			bar.color = c_work
		end
	end

	local function set_text()
		if state.phase == "idle" then
			label.text = "Pomo"
			timebox.text = "00:00"
			if show_progress then
				bar.value = 0
			end
			return
		end

		local t = fmt_mmss(state.remaining)
		if state.phase == "work" then
			label.text = string.format("Work %d/%d", current_work_index(), every_n)
			timebox.text = t
		else
			local kind = (state.break_kind == "long") and "L" or "S"
			label.text = "Break " .. kind
			timebox.text = t
		end
	end

	local function start_phase(phase, seconds, break_kind)
		state.phase = phase
		state.break_kind = break_kind
		state.total = seconds
		state.remaining = seconds
		state.running = true
		state.pending_transition = false
		set_color()
		set_text()

		play_sound(sound_start)

		if phase == "work" then
			notify(
				"Pomodoro",
				string.format("Work started (%s) — session %d/%d", fmt_mmss(seconds), current_work_index(), every_n)
			)
		else
			local kind = (break_kind == "long") and "Long break" or "Short break"
			notify("Pomodoro", string.format("%s started (%s)", kind, fmt_mmss(seconds)))
		end
	end

	local function stop_all()
		state.phase = "idle"
		state.break_kind = nil
		state.running = false
		state.remaining = 0
		state.total = 0
		state.pending_transition = false
		set_color()
		set_text()
		notify("Pomodoro", "Stopped")
	end

	local function next_phase()
		state.pending_transition = false

		if state.phase == "work" then
			state.sessions_done = state.sessions_done + 1
			local is_long = (state.sessions_done % every_n == 0)
			start_phase("break", is_long and long_s or short_s, is_long and "long" or "short")
		elseif state.phase == "break" then
			start_phase("work", work_s, nil)
		else
			start_phase("work", work_s, nil)
		end
	end

	local timer = gears.timer({
		timeout = 1,
		autostart = false,
		call_now = false,
		callback = function()
			if not state.running then
				return
			end

			state.remaining = state.remaining - 1
			if state.remaining < 0 then
				state.remaining = 0
			end

			if show_progress and state.total > 0 then
				bar.value = (state.total - state.remaining) / state.total
			end

			set_text()

			if state.remaining == 0 then
				-- Phase completed
				state.running = false
				set_color()

				play_sound(sound_finish)

				if state.phase == "work" then
					notify("Pomodoro", "Work complete ✅")
				else
					notify("Pomodoro", "Break complete ☕")
				end

				if auto_advance then
					next_phase()
				else
					state.pending_transition = true
					notify("Pomodoro", "Ready — manual advance (right click / skip)")
				end
			end
		end,
	})
	timer:start()

	local api = {}

	function api.widget()
		return container
	end

	function api.start_work()
		start_phase("work", work_s, nil)
	end

	function api.start_break(short)
		local use_short = (short ~= false)
		start_phase("break", use_short and short_s or long_s, use_short and "short" or "long")
	end

	function api.toggle()
		if state.phase == "idle" then
			api.start_work()
			return
		end

		if state.pending_transition then
			next_phase()
			return
		end

		state.running = not state.running
		set_color()
		notify(
			"Pomodoro",
			(state.running and "Resumed" or "Paused") .. " (" .. (state.phase == "work" and "Work" or "Break") .. ")"
		)
	end

	function api.skip()
		if state.phase == "idle" then
			return
		end
		notify("Pomodoro", "Advanced (" .. (state.phase == "work" and "Work" or "Break") .. ")")
		next_phase()
	end

	function api.stop()
		stop_all()
	end

	function api.status()
		return {
			phase = state.phase,
			break_kind = state.break_kind,
			running = state.running,
			remaining = state.remaining,
			total = state.total,
			sessions_done = state.sessions_done,
			current_work_index = current_work_index(),
			pending_transition = state.pending_transition,
			auto_advance = auto_advance,
			sound_enabled = sound_enabled,
			sound_finish = sound_finish,
			sound_start = sound_start,
		}
	end

	function api.set_auto_advance(v)
		auto_advance = not (v == false)
		notify("Pomodoro", "Auto-advance: " .. (auto_advance and "on" or "off"))
	end

	function api.set_sound(opts2)
		opts2 = opts2 or {}
		if opts2.enabled ~= nil then
			sound_enabled = (opts2.enabled == true)
		end
		if opts2.on_finish ~= nil then
			sound_finish = opts2.on_finish
		end
		if opts2.on_start ~= nil then
			sound_start = opts2.on_start
		end
		notify("Pomodoro", "Sound updated")
	end

	container:buttons(gears.table.join(
		awful.button({}, 1, function()
			api.toggle()
		end),
		awful.button({}, 2, function()
			api.stop()
		end),
		awful.button({}, 3, function()
			api.skip()
		end)
	))

	set_text()
	set_color()

	return api
end

return pomodoro
