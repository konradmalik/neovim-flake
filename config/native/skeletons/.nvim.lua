-- CHANGEME: this is skeleton file from neovim
local lsp = require("konrad.lsp")
-- lsp.add("ansiblels")
-- lsp.add("gopls")
-- lsp.add("jsonls")
lsp.add("nil_ls")
-- lsp.add("efm")
-- lsp.add("omnisharp")
-- lsp.add("pyright")
-- lsp.add("rust_analyzer")
-- lsp.add("lua_ls")
-- lsp.add("terraformls")
-- lsp.add("yamlls")

-- lsp.add("efm", {'prettier'})

local null = require("null-ls")
-- lsp.add("null-ls", null.builtins.formatting.black)
-- lsp.add("null-ls", null.builtins.formatting.isort)
-- lsp.add("null-ls", null.builtins.formatting.xmllint)
lsp.add("null-ls", null.builtins.formatting.nixpkgs_fmt)
-- lsp.add("null-ls", null.builtins.formatting.terraform_fmt)
-- lsp.add("null-ls", null.builtins.diagnostics.cspell)
-- lsp.add("null-ls", null.builtins.diagnostics.mypy)
-- lsp.add("null-ls", null.builtins.diagnostics.vale)

-- local dap = require("konrad.dap")
-- dap.add("cs")
-- dap.add("go")
-- dap.add("python")
