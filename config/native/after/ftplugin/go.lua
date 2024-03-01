local bufnr = vim.api.nvim_get_current_buf()

vim.opt.expandtab = false

local dap = require("konrad.dap")
local efm = require("konrad.lsp.efm")
local lsp = require("konrad.lsp")

lsp.init(require("konrad.lsp.configs.gopls"), bufnr)
lsp.init(efm.build_config("golangci-lint", { "golangci_lint" }), bufnr)
dap.init("go")
