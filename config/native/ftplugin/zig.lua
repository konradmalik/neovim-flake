local lsp = require("konrad.lsp")

local config = require("konrad.lsp.configs.zls").config()
lsp.start_and_attach(config)
