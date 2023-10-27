local lsp = require("konrad.lsp")

local config = require("konrad.lsp.configs.rust_analyzer").config
lsp.start_and_attach(config)
