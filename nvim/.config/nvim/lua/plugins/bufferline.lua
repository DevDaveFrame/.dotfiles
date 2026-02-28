--  Bufferline for buffer tabs
local LazyVimConfig = require("lazyvim.config")
return {
	"akinsho/bufferline.nvim",
	version = "*",
	dependencies = "nvim-tree/nvim-web-devicons",
	opts = {
		options = {
			-- stylua: ignore
			-- close_command = function(n) Snacks.bufdelete(n) end,
			-- stylua: ignore
			-- right_mouse_command = function(n) Snacks.bufdelete(n) end,
			diagnostics = "nvim_lsp",
			always_show_bufferline = true,
			diagnostics_indicator = function(_, _, diag)
				local icons = LazyVimConfig.icons.diagnostics
				local ret = (diag.error and icons.Error .. diag.error .. " " or "")
					.. (diag.warning and icons.Warn .. diag.warning or "")
				return vim.trim(ret)
			end,
			---@param opts bufferline.IconFetcherOpts
			get_element_icon = function(opts)
				return LazyVimConfig.icons.ft[opts.filetype]
			end,
		},
	},
}
