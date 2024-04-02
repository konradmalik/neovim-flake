local bufnr = vim.api.nvim_get_current_buf()

local dap = require("konrad.dap")
local lsp = require("konrad.lsp")

lsp.init(require("konrad.lsp.configs.efm").setup("pyefm", { "black", "isort" }), bufnr)
lsp.init(require("konrad.lsp.configs.pyright"), bufnr)
dap.init("python")
