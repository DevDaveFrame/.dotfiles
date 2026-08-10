require("config.lazy")
require("config.colors")
require("config.keymaps")
require("config.undotree")

vim.opt.conceallevel = 1
vim.opt.number = true
vim.opt.relativenumber = true
vim.g.autoformat = false
vim.diagnostic.config({
	virtual_text = true,
	underline = true,
	float = true,
	update_in_insert = true,
})
vim.opt.tabstop = 4 -- A TAB character looks like 4 spaces
vim.opt.expandtab = true -- Pressing the TAB key will insert spaces instead of a TAB character
vim.opt.softtabstop = 4 -- Number of spaces inserted instead of a TAB character
vim.opt.shiftwidth = 4 -- Number of spaces inserted when indenting

vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.wo[0][0].foldmethod = "expr"
vim.opt.foldenable = true
vim.opt.foldlevel = 99

vim.lsp.config("*", {
	capabilities = vim.lsp.protocol.make_client_capabilities(),
})

vim.filetype.add({
	extension = {
		mdx = "markdown",
	},
})
-- Enable easier nav across wrapped lines in markdown files
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		local opts = { buffer = true, silent = true }
		vim.keymap.set({ "n", "v" }, "j", "gj", opts)
		vim.keymap.set({ "n", "v" }, "k", "gk", opts)
		vim.keymap.set({ "n", "v" }, "0", "g0", opts)
		vim.keymap.set({ "n", "v" }, "$", "g$", opts)
	end,
})
