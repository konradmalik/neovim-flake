local lsp = require("konrad.lsp")
local dap = require("konrad.dap")

local lspconfig = require("konrad.lsp.configs.omnisharp").config
lsp.start_and_attach(lspconfig)
dap.initialize("cs")
