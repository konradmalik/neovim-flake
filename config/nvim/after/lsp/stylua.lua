local config = require("pde.lsp.configs.efm").config_from_single("stylua")
config.filetypes = { "lua" }
vim.lsp.config("stylua", config)