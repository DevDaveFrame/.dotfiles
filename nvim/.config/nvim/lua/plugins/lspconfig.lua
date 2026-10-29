return {
	{ "neovim/nvim-lspconfig", lazy = true },
	{ "mason-org/mason.nvim", cmd = "Mason", opts = {} },
	{
		"mason-org/mason-lspconfig.nvim",
		event = "VeryLazy",
		dependencies = {
			"neovim/nvim-lspconfig",
			"mason-org/mason.nvim",
		},
		opts = {
			ensure_installed = {
				"lua_ls",
				"gopls",
				"ts_ls",
				"eslint",
				"pyright",
				"ruff",
			},
		},
	},
}
