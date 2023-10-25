local lsp = require("konrad.lsp")
local efm = require("konrad.lsp.efm")

lsp.start_and_attach(efm.build_config("pyefm", { "black", "isort" }))
lsp.start_and_attach(require("konrad.lsp.configs.pyright").config())
