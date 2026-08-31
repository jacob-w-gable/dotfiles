-- Per-machine overrides for the Neovim config.
--
-- Copy to machine.lua (gitignored) and set only what differs on this computer.
-- Anything absent falls back to the defaults in the tracked config.
--
-- This exists because ~/.config/nvim is a symlink to the repo, so a
-- machine-specific tweak edited into a tracked file shows up as a permanently
-- dirty working tree and follows you onto every other machine.
--
-- For machine-local *plugins*, drop a spec file into lua/plugins/local/
-- instead - that whole directory is gitignored and imported automatically.

return {
	-- Where rust-analyzer puts its build artifacts. Useful when the default
	-- location is on a small disk. Defaults to ~/.cargo/nvim-target. Each
	-- workspace gets a subdirectory below this, so the whole tree is safe to
	-- delete when it grows too large.
	-- cargo_target_dir = "/mnt/somewhere/cargo/target-nvim",

	-- Override the rustfmt command rust-analyzer uses, e.g. for Leptos
	-- projects. Nil means rust-analyzer's built-in rustfmt.
	-- rustfmt_override = { "leptosfmt", "--stdin", "--rustfmt" },

	-- Where vimwiki and the work-diary template live. Nil disables both.
	-- notes_dir = os.getenv("HOME") .. "/Nextcloud/Documents/Notes",
}
