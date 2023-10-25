-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#omnisharp

-- https://github.com/Hoffs/omnisharp-extended-lsp.nvim
vim.cmd("packadd omnisharp-extended-lsp.nvim")

local binaries = require("konrad.binaries")
return {
    cmd = { binaries.omnisharp() },
    on_init = function(client, initialize_result)
        -- disable codelens for omnisharp because it makes it extremely slow
        client.server_capabilities.codeLensProvider = nil
        client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
    end,

    -- decompilation support via omnisharp-extended-lsp
    enableDecompilationSupport = true,
    handlers = {
        ["textDocument/definition"] = require("omnisharp_extended").handler,
    },

    -- Enables support for reading code style, naming convention and analyzer
    -- settings from .editorconfig.
    enable_editorconfig_support = true,

    -- Enables support for roslyn analyzers, code fixes and rulesets.
    enable_roslyn_analyzers = true,

    -- Specifies whether 'using' directives should be grouped and sorted during
    -- document formatting.
    organize_imports_on_format = true,

    -- Enables support for showing unimported types and unimported extension
    -- methods in completion lists. When committed, the appropriate using
    -- directive will be added at the top of the current file. This option can
    -- have a negative impact on initial completion responsiveness,
    -- particularly for the first few completion sessions after opening a
    -- solution.
    enable_import_completion = true,

    -- Only run analyzers against open files when 'enableRoslynAnalyzers' is
    -- true
    analyze_open_documents_only = true,
}
