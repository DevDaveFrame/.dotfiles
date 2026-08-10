return {
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("fzf-lua").setup({
			winopts = {
				height = 0.5,
				width = 1.0,
				row = 1.0,
				col = 0,
				preview = {
					layout = "horizontal",
					horizontal = "right:50%",
				},
			},
			fzf_colors = true,
			keymap = {
				builtin = {
					["<C-u>"] = "preview-page-up",
					["<C-d>"] = "preview-page-down",
				},
			},
		})
	end,
}
