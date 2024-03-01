local bufnr = vim.api.nvim_get_current_buf()

local dap = require("konrad.dap")
local efm = require("konrad.lsp.efm")
local lsp = require("konrad.lsp")

lsp.init(efm.build_config("pyefm", { "black", "isort" }), bufnr)
lsp.init(require("konrad.lsp.configs.pyright"), bufnr)
dap.init("python")
