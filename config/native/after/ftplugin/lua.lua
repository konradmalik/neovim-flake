local bufnr = vim.api.nvim_get_current_buf()

local lsp = require("pde.lsp")

lsp.init(require("pde.lsp.configs.efm").setup("stylua", { "stylua" }), bufnr)
lsp.init(require("pde.lsp.configs.lua_ls"), bufnr)
