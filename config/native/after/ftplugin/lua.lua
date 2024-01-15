local efm = require("konrad.lsp.efm")
local lsp = require("konrad.lsp")

lsp.start_and_attach(efm.build_config("stylua", { "stylua" }))
lsp.start_and_attach(require("konrad.lsp.configs.lua_ls").config)
