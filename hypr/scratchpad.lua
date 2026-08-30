-- Minimise, on a compositor that has no minimise.
--
-- Wayland has no minimised state, so awesome's Mod+n / Mod+Shift+n are reproduced with
-- the special workspace: pushing a window moves it there, popping brings the most
-- recently pushed one back. The stack is what makes it feel like unminimising rather
-- than "toggle a scratchpad" - awesome restores in reverse order too.
--
-- Only windows this module pushed are ever popped, which is the same guarantee
-- awesome/solo.lua gets from its _auto_minimized_by_solo flag: a window you sent to the
-- scratchpad yourself stays there.

local WORKSPACE = "special:minimised"

local M = {}

-- Addresses, most recently pushed last.
local stack = {}

local function remove_address(address)
	for i = #stack, 1, -1 do
		if stack[i] == address then
			table.remove(stack, i)
		end
	end
end

--- Send the focused window to the scratchpad.
function M.push()
	local window = hl.get_active_window()
	local workspace = hl.get_active_workspace()
	if not window or not workspace then
		return
	end

	remove_address(window.address)
	stack[#stack + 1] = window.address
	hl.dispatch(hl.dsp.window.move({
		workspace = WORKSPACE,
		window = "address:" .. window.address,
		follow = false,
	}))

	-- Move focus to something still on the workspace. Without this the window keeps
	-- focus from the scratchpad and a second press pushes it again instead of the next
	-- one, which is not what minimising twice should do.
	for _, other in ipairs(hl.get_windows()) do
		if other.address ~= window.address and other.workspace and other.workspace.id == workspace.id then
			hl.dispatch(hl.dsp.focus({ window = "address:" .. other.address }))
			return
		end
	end
end

--- Bring back the most recently pushed window that is still around.
function M.pop()
	local workspace = hl.get_active_workspace()
	if not workspace then
		return
	end

	while #stack > 0 do
		local address = table.remove(stack)
		local window = hl.get_window("address:" .. address)

		-- Skip windows that have since been closed, or that the user moved back out
		-- of the scratchpad by hand.
		if window then
			hl.dispatch(hl.dsp.window.move({
				workspace = tostring(workspace.id),
				window = "address:" .. address,
				follow = false,
			}))
			hl.dispatch(hl.dsp.focus({ window = "address:" .. address }))
			return
		end
	end
end

--- Forget a window, so a closed one is not popped later.
function M.forget(address)
	remove_address(address)
end

return M
