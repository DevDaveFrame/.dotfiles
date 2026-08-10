local function macro_recording()
	local reg = vim.fn.reg_recording()
	if reg ~= "" then
		return "  @" .. reg
	end
	return "--"
end

-- tokyonight.colors.setup() reads the configured style, not the live
-- background, so pass the style that matches the current background.
local function build_theme()
	local c = require("tokyonight.colors").setup({
		style = vim.o.background == "light" and "day" or "night",
	})
	return {
		normal = {
			a = { fg = c.bg, bg = c.blue, gui = "bold" },
			b = { fg = c.fg, bg = c.bg_highlight },
			c = { fg = c.fg_dark, bg = c.bg_statusline },
		},
		insert = { a = { fg = c.bg, bg = c.green, gui = "bold" } },
		visual = { a = { fg = c.bg, bg = c.magenta, gui = "bold" } },
		replace = { a = { fg = c.bg, bg = c.red, gui = "bold" } },
		command = { a = { fg = c.bg, bg = c.yellow, gui = "bold" } },
		inactive = {
			a = { fg = c.comment, bg = c.bg_statusline },
			b = { fg = c.comment, bg = c.bg_statusline },
			c = { fg = c.comment, bg = c.bg_statusline },
		},
	}
end

local function make_config()
	return {
		options = {
			theme = build_theme(),
			component_separators = "│",
			section_separators = { left = "", right = "" },
		},
		sections = {
			lualine_a = { { "mode", separator = { left = "" }, right_padding = 2 } },
			lualine_b = { "branch", "diff", "diagnostics" },
			lualine_c = { "%=" },
			lualine_x = { macro_recording, "filename" },
			lualine_y = { "filetype", "progress" },
			lualine_z = { { "location", separator = { right = "" }, left_padding = 2 } },
		},
		inactive_sections = {
			lualine_a = { "filename" },
			lualine_b = {},
			lualine_c = {},
			lualine_x = {},
			lualine_y = {},
			lualine_z = { "location" },
		},
	}
end

return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons", "folke/tokyonight.nvim" },
	config = function()
		require("lualine").setup(make_config())

		vim.api.nvim_create_autocmd({ "ColorScheme", "OptionSet" }, {
			pattern = { "*", "background" },
			callback = function()
				require("lualine").setup(make_config())
			end,
		})
	end,
}
