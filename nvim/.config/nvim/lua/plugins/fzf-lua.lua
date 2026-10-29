return {
	"ibhagwan/fzf-lua",
	cmd = "FzfLua",
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
			lsp = {
				code_actions = {
					-- Diff preview of what each action will do (needs git-delta).
					previewer = "codeaction_native",
					preview_pager = "delta --side-by-side --width=$FZF_PREVIEW_COLUMNS --hunk-header-style=omit --file-style=omit",
				},
			},
			keymap = {
				builtin = {
					["<C-u>"] = "preview-page-up",
					["<C-d>"] = "preview-page-down",
				},
			},
		})
	end,
}
