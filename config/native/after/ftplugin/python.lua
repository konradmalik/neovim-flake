local dap = require("konrad.dap")
local efm = require("konrad.lsp.efm")
local lsp = require("konrad.lsp")

lsp.start_and_attach(function() return efm.build_config("pyefm", { "black", "isort" }) end)
lsp.start_and_attach(require("konrad.lsp.configs.pyright").config)
dap.initialize("python")
