local lsp = require("konrad.lsp")
local efm = require("konrad.lsp.efm")

lsp.start_and_attach(efm.build_config("efmson", { "prettier", "jq" }))
lsp.start_and_attach(require("konrad.lsp.configs.jsonls").config)
