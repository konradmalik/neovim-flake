local bufnr = vim.api.nvim_get_current_buf()

local dap = require("konrad.dap")
local efm = require("konrad.lsp.efm")
local lsp = require("konrad.lsp")

lsp.start_and_attach(function() return efm.build_config("pyefm", { "black", "isort" }) end, bufnr)
lsp.init(require("konrad.lsp.configs.pyright"), bufnr)
dap.initialize("python")
