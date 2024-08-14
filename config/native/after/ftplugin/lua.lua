local bufnr = vim.api.nvim_get_current_buf()

local lsp = require("pde.lsp")

lsp.start(require("pde.lsp.configs.efm").setup("stylua", { "stylua" }, bufnr), { bufnr = bufnr })
lsp.start(require("pde.lsp.configs.lua_ls").config(bufnr), { bufnr = bufnr })
