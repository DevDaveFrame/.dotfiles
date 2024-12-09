-- LazyVim Overrides
vim.keymap.set("n", "<S-h>", "H", { desc = "cursor to first line" })
vim.keymap.set("n", "<S-l>", "L", { desc = "cursor to last line" })

-- Personal Preferences
vim.keymap.set('n', '<leader>pv', vim.cmd.Ex)
vim.keymap.set({'n', 'v'}, '<leader>y', '"+y')
vim.keymap.set({'n', 'v'}, '<leader>yy', '"+yy')

vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', '<C-d>', '<C-d>zz')

