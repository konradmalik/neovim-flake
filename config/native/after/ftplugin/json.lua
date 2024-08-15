local bufnr = vim.api.nvim_get_current_buf()

local lsp = require("pde.lsp")

lsp.start(
    require("pde.lsp.configs.efm").config_from_multi("efmson", { "prettier", "jq" }, bufnr),
    { bufnr = bufnr }
)
lsp.start(require("pde.lsp.configs.jsonls").config(bufnr), { bufnr = bufnr })
