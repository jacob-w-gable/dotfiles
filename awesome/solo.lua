-- "Solo mode": on a tag that is showing one window at a time -- either because
-- the layout is max-like, or because the focused client is fullscreen or
-- maximized -- every other client on the tag is minimized out of the way, and
-- restored when the tag leaves that state.
--
-- Only clients minimized *by* solo mode are restored, tracked with a private
-- _auto_minimized_by_solo flag, so a window you minimized yourself stays
-- minimized.

local awful = require("awful")
local gears = require("gears")
local apps = require("config.apps")

local M = {}

local function is_max_like_layout(t)
	local l = t and t.layout
	return l == awful.layout.suit.max or l == awful.layout.suit.max.fullscreen
end

-- Decide if we should be in "solo mode" on a tag:
-- Either the tag is a max-like layout, or the *focused* client on that tag is fullscreen/maximized.
local function tag_wants_solo(t)
	if not t then
		return false
	end
	if is_max_like_layout(t) then
		return true
	end
	local f = client.focus
	if f and (f.first_tag == t or f.sticky) then
		if f.fullscreen or f.maximized then
			return true
		end
	end
	return false
end

-- Optional: apps to never auto-minimize (dock, trays, your wallpaper popout, etc.)
local function exempt_from_solo(c)
	-- keep desktop/dock type alone; also your "Wallpaper Pop-out"
	if c.type == "dock" or c.type == "desktop" then
		return true
	end
	if c.name == apps.wallpaper_popout_name then
		return true
	end
	return false
end

-- Minimize all non-focused clients on the tag when in solo;
-- restore what we minimized when exiting solo.
function M.enforce(t)
	t = t or (client.focus and client.focus.first_tag) or awful.screen.focused().selected_tag
	if not t then
		return
	end

	local in_solo = tag_wants_solo(t)
	local focused = client.focus

	for _, c in ipairs(t:clients()) do
		if exempt_from_solo(c) then
		-- leave alone
		elseif in_solo then
			if c == focused then
				-- ensure focused is visible
				if c._auto_minimized_by_solo then
					c._auto_minimized_by_solo = nil
				end
				if c.minimized then
					c.minimized = false
				end
			else
				-- hide others (remember only our own changes)
				if not c.minimized then
					c.minimized = true
					c._auto_minimized_by_solo = true
				end
			end
		else
			-- leaving solo: restore only what we minimized
			if c._auto_minimized_by_solo then
				c._auto_minimized_by_solo = nil
				if c.minimized then
					c.minimized = false
				end
			end
		end
	end
end

function M.focus_next(delta)
	local s = awful.screen.focused()
	local t = s and s.selected_tag
	if not t then
		return
	end

	-- We treat "solo mode" generically (max layout OR focused client fullscreen/maximized)
	local solo = tag_wants_solo(t)

	if not solo then
		-- Normal behavior if not in solo
		awful.client.focus.byidx(delta)
		return
	end

	local list = t:clients()
	if #list == 0 then
		return
	end

	local cur = client.focus
	local idx = 1
	for i, c in ipairs(list) do
		if c == cur then
			idx = i
			break
		end
	end
	local nexti = ((idx - 1 + delta) % #list) + 1
	local target = list[nexti]

	if target.minimized then
		target.minimized = false
	end
	client.focus = target
	target:raise()

	M.enforce(t)
end

--- Wire the signals that re-run enforcement when the tag's state changes.
--
-- Separate from module load so rc.lua controls when this takes effect.
function M.connect()
	-- Re-enforce on important events
	client.connect_signal("focus", function(c)
		local t = c and (c.first_tag or c.screen.selected_tag)
		if t then
			M.enforce(t)
		end
	end)

	client.connect_signal("property::fullscreen", function(c)
		local t = c.first_tag or c.screen.selected_tag
		if t then
			M.enforce(t)
		end
	end)

	client.connect_signal("property::maximized", function(c)
		local t = c.first_tag or c.screen.selected_tag
		if t then
			M.enforce(t)
		end
	end)

	tag.connect_signal("property::layout", function(t)
		M.enforce(t)
	end)

	tag.connect_signal("property::selected", function(t)
		if t.selected then
			M.enforce(t)
		end
	end)

	client.connect_signal("manage", function(c)
		local t = c.first_tag or c.screen.selected_tag
		if t then
			gears.timer.delayed_call(function()
				M.enforce(t)
			end)
		end
	end)

	client.connect_signal("unmanage", function(c)
		local s = c.screen or awful.screen.focused()
		local t = s and s.selected_tag
		if t then
			gears.timer.delayed_call(function()
				M.enforce(t)
			end)
		end
	end)
end

return M
