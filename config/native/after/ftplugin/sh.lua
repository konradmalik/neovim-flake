local bufnr = vim.api.nvim_get_current_buf()

local lsp = require("pde.lsp")

lsp.start(
    require("pde.lsp.configs.efm").setup("sh", { "shfmt", "shellcheck" }, bufnr),
    { bufnr = bufnr }
)

