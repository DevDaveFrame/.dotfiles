-- Configure Kanagawa theme with both light and dark variants
vim.g.transparent_background = true
require("kanagawa").setup({
	background = {
		dark = "wave",
		light = "lotus", -- Use lotus variant for light mode
	},
	colors = {
		theme = {
			all = {
				ui = {
					bg_gutter = "none", -- Transparent gutter
				},
			},
		},
	},
	overrides = function(colors)
		local theme = colors.theme
		return {
			-- Make backgrounds transparent when explicitly requested
			NormalFloat = { bg = vim.g.transparent_background and "none" or theme.ui.bg },
			Normal = { bg = vim.g.transparent_background and "none" or theme.ui.bg },
		}
	end,
})

-- Set the colorscheme after configuration
vim.cmd([[colorscheme kanagawa]])

-- Fix lualine empty highlight groups that cause black backgrounds
vim.api.nvim_create_autocmd("ColorScheme", {
	callback = function()
		local colors = require("kanagawa.colors").setup().theme.ui
		-- Set backgrounds for lualine c sections that end up empty
		vim.api.nvim_set_hl(0, "lualine_c_normal", { bg = colors.bg_m1, fg = colors.fg })
		vim.api.nvim_set_hl(0, "lualine_c_insert", { bg = colors.bg_m1, fg = colors.fg })
		vim.api.nvim_set_hl(0, "lualine_c_visual", { bg = colors.bg_m1, fg = colors.fg })
		vim.api.nvim_set_hl(0, "lualine_c_replace", { bg = colors.bg_m1, fg = colors.fg })
		vim.api.nvim_set_hl(0, "lualine_c_command", { bg = colors.bg_m1, fg = colors.fg })
		vim.api.nvim_set_hl(0, "lualine_c_terminal", { bg = colors.bg_m1, fg = colors.fg })
	end,
})

-- This autocmd will ensure proper reloading when background changes
vim.api.nvim_create_autocmd("OptionSet", {
	pattern = "background",
	callback = function()
		vim.cmd("colorscheme kanagawa")
	end,
})

-- Trigger the lualine fix immediately
vim.cmd("doautocmd ColorScheme")
