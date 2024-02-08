vim.opt.expandtab = false

local dap = require("konrad.dap")
local efm = require("konrad.lsp.efm")
local lsp = require("konrad.lsp")

local config = require("konrad.lsp.configs.gopls").config
lsp.start_and_attach(config)
lsp.start_and_attach(function() return efm.build_config("golangci-lint", { "golangci_lint" }) end)
dap.initialize("go")
