return {
	"scottmckendry/cyberdream.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		-- Set the colorscheme
		require("cyberdream").setup({
			transparent = true,
			borderless_telescope = false,
			-- hide_fillchars = true,
		})
	end,
}
