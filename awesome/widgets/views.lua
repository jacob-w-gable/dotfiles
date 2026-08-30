-- One data source, many views.
--
-- A bar widget that polls something (the battery, the volume, the weather)
-- wants exactly one poller no matter how many screens are showing it, and one
-- widget object per screen. Sharing a single widget object across screens does
-- not work: awesome draws it on whichever bar claimed it last, so the others
-- come up missing that widget.
--
-- Each module keeps one of these, adds a view per screen, and calls set() when
-- its data changes.

local M = {}

--- Create a view set.
--
-- @tparam[opt] function apply How to paint a value onto one view. Defaults to
--   setting .markup, which suits a textbox. A graph wants add_value instead.
-- @tparam[opt] any initial Value to paint on views added before the first
--   set(), e.g. a "no data yet" placeholder.
function M.new(apply, initial)
	apply = apply or function(view, value)
		view.markup = value
	end

	-- Weak keys: a view for a screen that goes away should not be kept alive
	-- here, and must not keep receiving updates.
	local views = setmetatable({}, { __mode = "k" })
	local current = initial

	local set = {}

	--- Register a view to receive updates, and paint the current value on it.
	--
	-- `key` must be an object the bar itself references (a widget), because the
	-- table is weak-keyed and anything else is collected straight away. When a
	-- view needs more than one object, a graph and its tooltip say, pass them
	-- as `payload`. It stays reachable for as long as the key does.
	function set.add(key, payload)
		local view = payload or key
		views[key] = view
		if current ~= nil then
			apply(view, current)
		end
		return key
	end

	--- Push a new value to every registered view.
	function set.set(value)
		current = value
		for _, view in pairs(views) do
			apply(view, value)
		end
	end

	--- Run fn once, on the first call only. Used to start a poller lazily, so
	--- nothing polls until a screen actually asks for the widget.
	local started = false
	function set.start_once(fn)
		if started then
			return
		end
		started = true
		fn()
	end

	return set
end

return M
