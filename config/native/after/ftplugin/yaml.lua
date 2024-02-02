local efm = require("konrad.lsp.efm")
local lsp = require("konrad.lsp")

lsp.start_and_attach(function() return efm.build_config("prettier", { "prettier" }) end)
lsp.start_and_attach(require("konrad.lsp.configs.yamlls").config)
