local bufnr = vim.api.nvim_get_current_buf()

local lsp = require("pde.lsp")

lsp.start(
    require("pde.lsp.configs.efm").config_from_multi("pyefm", { "black", "isort" }, bufnr),
    { bufnr = bufnr }
)
lsp.start(require("pde.lsp.configs.pyright").config(bufnr), { bufnr = bufnr })
