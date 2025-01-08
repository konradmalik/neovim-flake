local config = require("pde.lsp.configs.efm").config_from_multi("sh", { "shfmt", "shellcheck" })
config.filetypes = { "sh" }
return config
