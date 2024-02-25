local bufnr = vim.api.nvim_get_current_buf()
local dap = require("konrad.dap")
local lsp = require("konrad.lsp")

lsp.init(require("konrad.lsp.configs.roslyn_ls"), bufnr)
dap.initialize("cs")
