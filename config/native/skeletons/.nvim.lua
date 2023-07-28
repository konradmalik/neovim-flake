-- CHANGEME: this is skeleton file from neovim
local lsp = require("konrad.lsp")
-- lsp.add("ansiblels")
-- lsp.add("gopls")
-- lsp.add("jsonls")
-- lsp.add("lua_ls")
lsp.add("nil_ls")
-- lsp.add("omnisharp")
-- lsp.add("pyright")
-- lsp.add("rust_analyzer")
-- lsp.add("terraformls")
-- lsp.add("yamlls")

lsp.add("efm", {
    'nixpkgs_fmt',
    -- 'terraform_fmt'
})
lsp.initialize()

-- local dap = require("konrad.dap")
-- dap.add("cs")
-- dap.add("go")
-- dap.add("python")
-- dap.initialize()
