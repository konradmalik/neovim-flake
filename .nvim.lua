local lsp = require("konrad.lsp")
lsp.add("nil_ls")
lsp.add("lua_ls")

lsp.add("efm", { 'nixpkgs_fmt' })

lsp.initialize()
