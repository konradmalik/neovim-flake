local lsp = require("konrad.lsp")
local dap = require("konrad.dap")

local csconfig = require("konrad.languages.csharp").current_config()

local lspconfig = require("konrad.lsp.configs." .. csconfig.lsp).config
lsp.start_and_attach(lspconfig)
dap.initialize("cs")
