local efm = require("konrad.lsp.efm")
local lsp = require("konrad.lsp")
local dap = require("konrad.dap")

local config = require("konrad.lsp.configs.gopls").config
lsp.start_and_attach(config)
lsp.start_and_attach(efm.build_config("golangci-lint", { "golangci_lint" }))
dap.initialize("go")
