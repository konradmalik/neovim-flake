local lsp = require("konrad.lsp")
local efm = require("konrad.lsp.efm")

local config = require("konrad.lsp.configs.gopls").config()
lsp.start_and_attach(config)
lsp.start_and_attach(efm.build_config("golangci-lint", { "golangci_lint" }))
