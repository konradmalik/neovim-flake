local efm = require("konrad.lsp.efm")
local lsp = require("konrad.lsp")

lsp.start_and_attach(function() return efm.build_config("efmson", { "prettier", "jq" }) end)
lsp.init(require("konrad.lsp.configs.jsonls"))
