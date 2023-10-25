local lsp = require("konrad.lsp")

local config = require("konrad.lsp.configs.omnisharp").config()
lsp.start_and_attach(config)
