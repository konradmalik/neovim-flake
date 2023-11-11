local lsp = require("konrad.lsp")
local dap = require("konrad.dap")

local config = require("konrad.lsp.configs.csharp_ls").config
lsp.start_and_attach(config)
dap.initialize("cs")
