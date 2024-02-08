vim.opt.expandtab = false

local lsp = require("konrad.lsp")

local config = require("konrad.lsp.configs.gopls").config
lsp.start_and_attach(config)
