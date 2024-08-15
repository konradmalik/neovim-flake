local bufnr = vim.api.nvim_get_current_buf()

local lsp = require("pde.lsp")

lsp.start(require("pde.lsp.configs.efm").config_from_single("prettier", bufnr), { bufnr = bufnr })
lsp.start(require("pde.lsp.configs.ltex_ls").config(bufnr), { bufnr = bufnr })
