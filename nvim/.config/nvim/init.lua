require("config.lazy")
require("config.colors")
require("config.keymaps")
require("config.undotree")

vim.opt.termguicolors = true
vim.opt.conceallevel = 1
vim.opt.number = true
vim.opt.relativenumber = true
vim.g.autoformat = false
vim.diagnostic.config({
	-- Short virtual text on every line except the cursor line, where virtual_lines
	-- renders the full message underneath instead (avoids double-reporting).
	virtual_text = { current_line = false },
	virtual_lines = { current_line = true },
	underline = true,
	float = { border = "rounded", source = true },
	-- Re-linting on every keystroke is noisy and makes servers do redundant work.
	update_in_insert = false,
	jump = {
		-- 0.12 dropped jump.float; on_jump is the replacement, so ]d / [d land on
		-- a diagnostic and pop the float in one keystroke.
		on_jump = function(_, bufnr)
			vim.diagnostic.open_float({ bufnr = bufnr, scope = "cursor", focus = false })
		end,
	},
})
vim.opt.tabstop = 4 -- A TAB character looks like 4 spaces
vim.opt.expandtab = true -- Pressing the TAB key will insert spaces instead of a TAB character
vim.opt.softtabstop = 4 -- Number of spaces inserted instead of a TAB character
vim.opt.shiftwidth = 4 -- Number of spaces inserted when indenting

-- Note: use vim.opt (global default), not vim.wo[0][0] -- the latter is
-- :setlocal-scoped to a single (window, buffer) pair, so folds silently revert
-- to foldmethod=manual as soon as you open a second buffer.
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldmethod = "expr"
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
