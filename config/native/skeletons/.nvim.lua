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

-- lsp.add("efm", {'nixpkgs_fmt'})

lsp.add("null-ls", function(null)
    return {
        -- null.builtins.formatting.black,
        -- null.builtins.diagnostics.cspell,
        -- null.builtins.formatting.isort,
        -- null.builtins.diagnostics.mypy,
        null.builtins.formatting.nixpkgs_fmt,
        -- null.builtins.formatting.terraform_fmt,
        -- null.builtins.diagnostics.vale,
        -- null.builtins.formatting.xmllint,
    }
end)

-- local dap = require("konrad.dap")
-- dap.add("cs")
-- dap.add("go")
-- dap.add("python")

lsp.initialize()
