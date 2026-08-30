-- Binding registration, with the descriptions awesome attaches to every key.
--
-- awful.key takes { description = ..., group = ... } and the hotkeys popup reads it back.
-- Hyprland has no such notion: hyprctl reports every Lua-backed bind as "__lua" plus an
-- index, so a help list built from what the compositor knows is unreadable.
--
-- This wraps hl.bind to keep the description beside the binding it describes - one
-- source of truth rather than a parallel list to drift - and writes the collected set
-- out for scripts/hotkeys to display.

local M = {}

local registry = {}

--- Register a key binding.
--
-- keys and action are passed straight to hl.bind; group and description are kept for
-- the help list. opts, when given, goes to hl.bind as its third argument.
function M.bind(keys, action, group, description, opts)
	assert(type(keys) == "string", "bind: keys must be a string")
	assert(type(group) == "string", "bind: group must be a string")
	assert(type(description) == "string", "bind: description must be a string")

	registry[#registry + 1] = { keys = keys, group = group, description = description }

	if opts then
		hl.bind(keys, action, opts)
	else
		hl.bind(keys, action)
	end
end

--- Write the collected bindings where scripts/hotkeys can read them.
--
-- Tab-separated rather than JSON to keep the reader a plain shell script, and rewritten
-- on every config load so it cannot describe a binding that no longer exists.
function M.export()
	local path = (os.getenv("XDG_RUNTIME_DIR") or "/tmp") .. "/hypr-binds"

	local file = io.open(path, "w")
	if not file then
		return
	end

	for _, entry in ipairs(registry) do
		file:write(entry.group, "\t", entry.keys, "\t", entry.description, "\n")
	end
	file:close()
end

return M
