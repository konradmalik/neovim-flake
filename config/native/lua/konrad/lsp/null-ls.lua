-- https://github.com/jose-elias-alvarez/null-ls.nvim
local null_ls = require("null-ls")

local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics
local code_actions = null_ls.builtins.code_actions

local binaries = require('konrad.binaries')

local default_sources = {
    formatting.prettier.with({
        command = binaries.prettier,
        timeout = 10000,
        extra_filetypes = { "toml" },
        extra_args = { "--plugin-search-dir", binaries.prettier_plugin_toml },
    }),
    formatting.shfmt.with({
        command = binaries.shfmt,
    }),

    diagnostics.shellcheck.with({
        command = binaries.shellcheck,
    }),

    code_actions.gitsigns,
    code_actions.shellcheck.with({
        command = binaries.shellcheck,
    }),
}

-- null_ls has a 'should_attach' fuction where we could limit
-- the number of buffers it attaches to but we need it in all buffers in
-- fact due to gitsigns
null_ls.setup({
    debug = false,
    sources = default_sources,
})
