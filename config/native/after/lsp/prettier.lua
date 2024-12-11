local config = require("pde.lsp.configs.efm").config_from_single("prettier")
config.filetypes = { "markdown", "yaml" }
vim.lsp.config("prettier", config)
