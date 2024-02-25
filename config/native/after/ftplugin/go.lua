local bufnr = vim.api.nvim_get_current_buf()

vim.opt.expandtab = false

local dap = require("konrad.dap")
local efm = require("konrad.lsp.efm")
local lsp = require("konrad.lsp")

lsp.init(require("konrad.lsp.configs.gopls"), bufnr)
lsp.start_and_attach(
    function() return efm.build_config("golangci-lint", { "golangci_lint" }) end,
    bufnr
)
dap.initialize("go")
