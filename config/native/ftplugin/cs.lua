local lsp = require("konrad.lsp")
local dap = require("konrad.dap")

local config = require("konrad.lsp.configs.omnisharp").config()
lsp.start_and_attach(config)
dap.initialize("cs")
