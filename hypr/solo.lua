-- "Solo mode": on a workspace that is showing one window at a time - because the
-- focused window is fullscreen or maximised - every other window on the workspace is
-- hidden out of the way, and brought back when the workspace leaves that state.
--
-- This is awesome/solo.lua. The behaviour is the same and so are its guarantees; the
-- mechanism differs because Wayland has no minimise:
--
--   awesome           here
--   client.minimized  moved to a special workspace
--   _auto_minimized   the `hidden` table below
--
-- Only windows solo mode hid are ever restored, so one you sent to the scratchpad
-- yourself stays there. That is the whole point of tracking them rather than restoring
-- everything on the special workspace.
--
-- awesome also triggers on max-like layouts. Hyprland has no max layout - see
-- layouts.lua - so fullscreen and maximised are the whole trigger.

local settings = require("config")

local HIDDEN_WORKSPACE = "special:solo"

local M = {}

-- address -> workspace id it was hidden from.
local hidden = {}

-- Set while this module is moving windows, so its own dispatches do not re-enter
-- through the events it subscribes to.
local applying = false

--- Is this window showing alone, i.e. covering the workspace?
local function is_solo(window)
	return window.fullscreen ~= 0 or window.maximized
end

--- Windows on a workspace, excluding any this module has hidden.
local function windows_on(workspace_id)
	local list = {}
	for _, window in ipairs(hl.get_windows()) do
		if window.workspace and window.workspace.id == workspace_id and not hidden[window.address] then
			list[#list + 1] = window
		end
	end
	table.sort(list, function(a, b)
		return a.address < b.address
	end)
	return list
end

--- Hide everything on the workspace except `keep`.
local function hide_others(workspace_id, keep)
	for _, window in ipairs(windows_on(workspace_id)) do
		if window.address ~= keep then
			hidden[window.address] = workspace_id
			hl.dispatch(hl.dsp.window.move({
				workspace = HIDDEN_WORKSPACE,
				window = "address:" .. window.address,
				follow = false,
			}))
		end
	end
end

--- Bring back everything solo mode hid from this workspace.
local function restore(workspace_id)
	for address, from in pairs(hidden) do
		if from == workspace_id then
			hidden[address] = nil
			if hl.get_window("address:" .. address) then
				hl.dispatch(hl.dsp.window.move({
					workspace = tostring(workspace_id),
					window = "address:" .. address,
					follow = false,
				}))
			end
		end
	end
end

--- Bring the workspace into line with whether its focused window is showing alone.
function M.enforce()
	if not settings.solo or applying then
		return
	end

	local workspace = hl.get_active_workspace()
	local window = hl.get_active_window()
	if not workspace or not window then
		return
	end

	applying = true
	if is_solo(window) then
		hide_others(workspace.id, window.address)
	else
		restore(workspace.id)
	end
	applying = false
end

--- Focus the next window on the workspace, by index.
--
-- awesome walks the tag's client list, which is what makes Mod+j/k useful in a max
-- layout where directional focus has nowhere to go. Off a solo workspace there is a
-- real geometry to move through, so that falls through to directional focus.
function M.focus_next(delta)
	local window = hl.get_active_window()
	local workspace = hl.get_active_workspace()

	if not window or not workspace or not is_solo(window) then
		hl.dispatch(hl.dsp.focus({ direction = delta > 0 and "down" or "up" }))
		return
	end

	-- On a solo workspace the others are hidden, so the list to cycle is this window
	-- plus everything solo mode took from here.
	local list = { window.address }
	for address, from in pairs(hidden) do
		if from == workspace.id then
			list[#list + 1] = address
		end
	end
	table.sort(list)

	if #list < 2 then
		return
	end

	local index = 1
	for i, address in ipairs(list) do
		if address == window.address then
			index = i
			break
		end
	end

	local target = list[(index - 1 + delta) % #list + 1]

	-- Swap the two: the incoming window takes the workspace, the outgoing one takes
	-- its place in hiding.
	applying = true
	hidden[target] = nil
	hl.dispatch(hl.dsp.window.move({
		workspace = tostring(workspace.id),
		window = "address:" .. target,
		follow = false,
	}))
	hidden[window.address] = workspace.id
	hl.dispatch(hl.dsp.window.move({
		workspace = HIDDEN_WORKSPACE,
		window = "address:" .. window.address,
		follow = false,
	}))
	hl.dispatch(hl.dsp.focus({ window = "address:" .. target }))
	applying = false
end

--- Stop tracking a window, so a closed one is not restored later.
function M.forget(address)
	hidden[address] = nil
end

function M.connect()
	if not settings.solo then
		return
	end

	hl.on("window.active", M.enforce)
	hl.on("window.open", M.enforce)
	hl.on("workspace.active", M.enforce)
end

return M
