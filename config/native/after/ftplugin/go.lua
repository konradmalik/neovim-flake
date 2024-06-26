local bufnr = vim.api.nvim_get_current_buf()

vim.opt.expandtab = false

local dap = require("pde.dap")
local lsp = require("pde.lsp")

lsp.init(require("pde.lsp.configs.gopls").config(), bufnr)
lsp.init(require("pde.lsp.configs.efm").setup("golangci-lint", { "golangci_lint" }), bufnr)
dap.init("go")
