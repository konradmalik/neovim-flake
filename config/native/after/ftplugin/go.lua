local bufnr = vim.api.nvim_get_current_buf()

vim.opt.expandtab = false

local dap = require("pde.dap")
local lsp = require("pde.lsp")

lsp.start(require("pde.lsp.configs.gopls").config(bufnr), { bufnr = bufnr })
lsp.start(
    require("pde.lsp.configs.efm").setup("golangci-lint", { "golangci_lint" }),
    { bufnr = bufnr }
)
dap.init("go")
