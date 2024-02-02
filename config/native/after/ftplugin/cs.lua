local dap = require("konrad.dap")
local lsp = require("konrad.lsp")

local lspconfig = require("konrad.lsp.configs.roslyn_ls").config
lsp.start_and_attach(lspconfig)
dap.initialize("cs")
