-- The layouts Mod+space cycles through.
--
-- awesome/config/layouts.lua cycles seven: floating, lain centerwork, tile, tile.left,
-- fair, fair.horizontal and max. Hyprland ships three - dwindle, master and scrolling -
-- so this is the closest honest mapping rather than a reproduction:
--
--   dwindle           tile / fair, splitting the focused window in half
--   master            tile, with a real master area
--   master (centre)   lain's centerwork, master in the middle
--   scrolling         no awesome equivalent; kept because it earns its place
--   floating          floating
--
-- max is not a layout here. It is a per-window state, and solo.lua turns it into the
-- workspace-wide behaviour awesome's max layout has.

local ORDER = {
	{ name = "dwindle", layout = "dwindle" },
	{ name = "master", layout = "master", orientation = "left" },
	{ name = "centre", layout = "master", orientation = "center" },
	{ name = "scrolling", layout = "scrolling" },
	{ name = "floating", layout = "dwindle", floating = true },
}

local M = {}

local current = 1

-- Windows the floating layout floated, so leaving it re-tiles exactly those.
local floated = {}

--- The name of the layout in effect, for the bar's layout indicator.
function M.current()
	return ORDER[current].name
end

--- Apply a layout by index.
local function apply(index)
	local entry = ORDER[index]

	hl.config({ general = { layout = entry.layout } })

	if entry.orientation then
		hl.config({ master = { orientation = entry.orientation } })
	end

	-- "floating" is not a Hyprland layout. Every window is floated instead, which is
	-- what awesome's floating layout amounts to - and re-tiled on the way out, since
	-- leaving the layout has to undo it. Only windows floated here are re-tiled, so one
	-- floated by a rule or by hand stays floating.
	if entry.floating then
		floated = {}
		for _, window in ipairs(hl.get_windows()) do
			if not window.floating then
				floated[#floated + 1] = window.address
				hl.dispatch(hl.dsp.window.float({
					action = "enable",
					window = "address:" .. window.address,
				}))
			end
		end
	elseif #floated > 0 then
		for _, address in ipairs(floated) do
			if hl.get_window("address:" .. address) then
				hl.dispatch(hl.dsp.window.float({
					action = "disable",
					window = "address:" .. address,
				}))
			end
		end
		floated = {}
	end

	-- Written where waybar's layout module can read it without asking Hyprland, which
	-- it has no way to do for a value the compositor does not track.
	local path = os.getenv("XDG_RUNTIME_DIR") .. "/hypr-layout"
	local file = io.open(path, "w")
	if file then
		file:write(entry.name, "\n")
		file:close()
	end

	hl.exec_cmd("pkill -RTMIN+8 waybar")
end

--- Step through the list, wrapping. delta is 1 or -1.
function M.cycle(delta)
	current = (current - 1 + delta) % #ORDER + 1
	apply(current)
end

function M.init()
	apply(current)
end

return M
