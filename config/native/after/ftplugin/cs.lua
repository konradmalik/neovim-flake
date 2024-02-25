local dap = require("konrad.dap")
local lsp = require("konrad.lsp")

lsp.init(require("konrad.lsp.configs.roslyn_ls"))
dap.initialize("cs")
