require("tokyonight").setup({
	style = "night",
	light_style = "day",
	transparent = true,
})

vim.cmd([[colorscheme tokyonight]])

-- Neovim 0.11 detects system background too late (after colorscheme loads),
-- so re-apply on the OptionSet event it fires when detection completes.
vim.api.nvim_create_autocmd("OptionSet", {
	pattern = "background",
	callback = function()
		vim.cmd("colorscheme tokyonight")
	end,
})
