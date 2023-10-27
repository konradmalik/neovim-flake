local lsp = require("konrad.lsp")
local efm = require("konrad.lsp.efm")

lsp.start_and_attach(efm.build_config("sh", { "shfmt", "shellcheck" }))
