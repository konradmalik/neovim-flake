local config = require("pde.lsp.configs.efm").config_from_single("taplo")
config.filetypes = { "toml" }
vim.lsp.config("taplo", config)
