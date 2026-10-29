-- Overrides
-- get rid of pesky sub in favor of mini.surround
vim.keymap.set("n", "s", "<Nop>")

-- Easy Commands
vim.keymap.set("n", "<leader>q", ":quit<CR>")
vim.keymap.set("n", "<leader>s", ":write<CR>")
-- LazyVim Overrides
vim.keymap.set("n", "<S-h>", "H", { desc = "cursor to first line" })
vim.keymap.set("n", "<S-l>", "L", { desc = "cursor to last line" })

-- Personal Preferences
vim.keymap.set("n", "-", ":Oil<CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "<leader><Space>", function()
	require("fzf-lua").files({ resume = true })
end)
vim.keymap.set("n", "<leader>ps", function()
	require("fzf-lua").live_grep_native({ resume = true })
end)
vim.keymap.set("n", "<leader>ph", function()
	require("fzf-lua").oldfiles()
end)
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y')
vim.keymap.set({ "n", "v" }, "<leader>yy", '"+yy')

vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-d>", "<C-d>zz")

-- LSP Nav
vim.keymap.set("n", "gd", function()
	require("fzf-lua").lsp_definitions({ jump1 = true })
end)
vim.keymap.set("n", "gD", function()
	require("fzf-lua").lsp_declarations({ jump1 = true })
end)
vim.keymap.set("n", "gr", function()
	require("fzf-lua").lsp_references()
end)
vim.keymap.set("n", "<leader>ls", function()
	require("fzf-lua").lsp_document_symbols()
end, { desc = "LSP document symbols" })
vim.keymap.set("n", "<leader>lS", function()
	require("fzf-lua").lsp_workspace_symbols()
end, { desc = "LSP workspace symbols" })

-- Diagnostics / code actions
-- Built-ins already cover a lot: <C-W>d (float), ]d / [d (jump), gra (code
-- action), grn (rename), grr (references), gO (symbols). These are leader-style
-- aliases for the ones reached most often.
vim.keymap.set("n", "<leader>cd", function()
	vim.diagnostic.open_float({ scope = "line" })
end, { desc = "Line diagnostics (float)" })
vim.keymap.set({ "n", "v" }, "<leader>ca", function()
	require("fzf-lua").lsp_code_actions()
end, { desc = "Code action" })
vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename symbol" })
vim.keymap.set("n", "<leader>cl", function()
	vim.diagnostic.config({ virtual_lines = not vim.diagnostic.config().virtual_lines })
end, { desc = "Toggle diagnostic virtual_lines" })

-- Pickers
vim.keymap.set("n", "<leader>pb", function()
	require("fzf-lua").buffers()
end, { desc = "buffers" })
vim.keymap.set("n", "<leader>pd", function()
	require("fzf-lua").diagnostics_document()
end, { desc = "document diagnostics" })
vim.keymap.set("n", "<leader>pD", function()
	require("fzf-lua").diagnostics_workspace()
end, { desc = "workspace diagnostics" })

-- Open in cursor
vim.keymap.set("n", "<leader>xc", function()
	local file = vim.fn.expand("%:p")
	local line = vim.fn.line(".")
	local root = vim.fs.root(0, ".git") or vim.fn.getcwd()
	local cmd = string.format("silent !cursor -g -r %s %s:%s", vim.fn.shellescape(root), vim.fn.shellescape(file), line)
	vim.cmd(cmd)
end, { desc = "Open file in Cursor (project)" })

vim.keymap.set("n", "<leader>td", function()
	local pos = vim.api.nvim_win_get_cursor(0)[2]
	local line = vim.api.nvim_get_current_line()
	local nline = line:sub(0, pos) .. os.date("%x") .. line:sub(pos + 1)
	vim.api.nvim_set_current_line(nline)
end, { desc = "print today's date in buffer" })

-- Buffer navigation
vim.api.nvim_create_user_command("BufOnly", function()
	local cur = vim.api.nvim_get_current_buf()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if buf ~= cur and vim.bo[buf].buflisted then
			pcall(vim.api.nvim_buf_delete, buf, { force = false })
		end
	end
end, {})

vim.keymap.set("n", "<leader>bb", "<C-^>", { desc = "goto prev buffer" })
vim.keymap.set("n", "<leader>b<BS>", ":bdelete<CR>", { desc = "close buffer" })
vim.keymap.set("n", "<leader>bO", "<cmd>BufOnly<CR>", { desc = "delete all other buffers" })
