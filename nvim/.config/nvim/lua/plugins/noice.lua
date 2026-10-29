return {
	"folke/noice.nvim",
	event = "VeryLazy",
	opts = {
		lsp = {
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
				["cmp.entry.get_documentation"] = true,
			},
		},
		routes = {
			{
				filter = {
					event = "msg_show",
					any = {
						{ find = "%d+L, %d+B" },
						{ find = "; after #%d+" },
						{ find = "; before #%d+" },
					},
				},
			},
			{
				filter = {
					event = "msg_show",
					find = "Type Name Content", -- this finds the registers output
				},
				view = "popup",
				opts = { enter = true, timeout = false },
			},
		},
		presets = {
			bottom_search = false,
			command_palette = true,
			long_message_to_split = true,
		},
	},
}
