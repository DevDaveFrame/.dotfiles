require("config.lazy")
require("config.colors")
require("config.telescope")
require("config.treesitter")
require("config.undotree")
require("config.lualine")


vim.opt.conceallevel = 1
vim.opt.number = true
vim.opt.relativenumber = true

vim.diagnostic.config({ 
	virtual_text = true,
	underline = true,
	float = true,
	update_in_insert=true
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup('lsp_attach_disable_ruff_hover', { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client == nil then
      return
    end
    if client.name == 'ruff' then
      -- Disable hover in favor of Pyright
      client.server_capabilities.hoverProvider = false
    end
  end,
  desc = 'LSP: Disable hover capability from Ruff',
})
