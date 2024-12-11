local config = require("pde.lsp.configs.efm").config_from_single("golangci_lint")
config.filetypes = { "go" }
vim.lsp.config("golangci_lint", config)
