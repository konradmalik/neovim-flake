local config = require("pde.lsp.configs.efm").config_from_multi("efmson", { "prettier", "jq" })
config.filetypes = { "json", "jsonc" }
return config
