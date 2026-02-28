-- Easy Commands
vim.keymap.set("n", "<leader>q", ":quit<CR>")
vim.keymap.set("n", "<leader>s", ":write<CR>")
-- LazyVim Overrides
vim.keymap.set("n", "<S-h>", "H", { desc = "cursor to first line" })
vim.keymap.set("n", "<S-l>", "L", { desc = "cursor to last line" })

-- Personal Preferences
vim.keymap.set("n", "-", ":Oil<CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "<leader><Space>", function()
	require("fzf-lua").files()
end)
vim.keymap.set("n", "<leader>ps", function()
	require("fzf-lua").live_grep_native()
end)
vim.keymap.set("n", "<leader>ph", function()
	require("fzf-lua").oldfiles()
end)
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y')
vim.keymap.set({ "n", "v" }, "<leader>yy", '"+yy')

vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-d>", "<C-d>zz")

-- LSP Nav
vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set("n", "gD", vim.lsp.buf.declaration)
vim.keymap.set("n", "gr", vim.lsp.buf.references)

-- Open in cursor
vim.keymap.set("n", "<leader>oc", function()
	local file = vim.fn.expand("%:p")
	local line = vim.fn.line(".")
	local root = vim.fs.root(0, ".git") or vim.fn.getcwd()
	local cmd = string.format("silent !cursor -g -r %s %s:%s", vim.fn.shellescape(root), vim.fn.shellescape(file), line)
	vim.cmd(cmd)
end, { desc = "Open file in Cursor (project)" })

-- Open ObsidianToday
vim.keymap.set("n", "<leader>ot", "<cmd>ObsidianToday<CR>")
vim.keymap.set("n", "<leader>oog", "<cmd>ObsidianNewFromTemplate<CR>")

vim.keymap.set("n", "<leader>td", function()
	local pos = vim.api.nvim_win_get_cursor(0)[2]
	local line = vim.api.nvim_get_current_line()
	local nline = line:sub(0, pos) .. os.date("%x") .. line:sub(pos + 1)
	vim.api.nvim_set_current_line(nline)
end, { desc = "print today's date in buffer" })

vim.keymap.set("n", "<leader>bb", "<C-^>", { desc = "goto prev buffer" })
vim.keymap.set("n", "<leader>b<BS>", ":bdelete<CR>", { desc = "close buffer" })
vim.keymap.set("n", "<leader>bO", ':%bdelete|edit #|normal`"<CR>', { desc = "delete all other buffers" })
