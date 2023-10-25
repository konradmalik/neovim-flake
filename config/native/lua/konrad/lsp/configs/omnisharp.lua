-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#omnisharp

-- https://github.com/Hoffs/omnisharp-extended-lsp.nvim
vim.cmd("packadd omnisharp-extended-lsp.nvim")

local binaries = require("konrad.binaries")
local configs = require("konrad.lsp.configs")
local function register_cap()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.workspace.workspaceFolders = false -- https://github.com/OmniSharp/omnisharp-roslyn/issues/909
    return capabilities
end

local M = {}

M.options = {
    -- Only run analyzers against open files when 'enableRoslynAnalyzers' is
    -- true
    analyze_open_documents_only = true,
    -- decompilation support via omnisharp-extended-lsp
    enableDecompilationSupport = true,
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
}

M.config = function()
    local cmd = { binaries.omnisharp() }
    -- Append hard-coded command arguments
    table.insert(cmd, "-z") -- https://github.com/OmniSharp/omnisharp-vscode/pull/4300
    vim.list_extend(cmd, { "--hostPID", tostring(vim.fn.getpid()) })
    table.insert(cmd, "DotNet:enablePackageRestore=false")
    vim.list_extend(cmd, { "--encoding", "utf-8" })
    table.insert(cmd, "--languageserver")

    -- Append configuration-dependent command arguments
    if M.options.enable_editorconfig_support then
        table.insert(cmd, "FormattingOptions:EnableEditorConfigSupport=true")
    end

    if M.options.organize_imports_on_format then
        table.insert(cmd, "FormattingOptions:OrganizeImports=true")
    end

    if M.options.enable_ms_build_load_projects_on_demand then
        table.insert(cmd, "MsBuild:LoadProjectsOnDemand=true")
    end

    if M.options.enable_roslyn_analyzers then
        table.insert(cmd, "RoslynExtensionsOptions:EnableAnalyzersSupport=true")
    end

    if M.options.enable_import_completion then
        table.insert(cmd, "RoslynExtensionsOptions:EnableImportCompletion=true")
    end

    if M.options.sdk_include_prereleases then
        table.insert(cmd, "Sdk:IncludePrereleases=true")
    end

    if M.options.analyze_open_documents_only then
        table.insert(cmd, "RoslynExtensionsOptions:AnalyzeOpenDocumentsOnly=true")
    end

    return {
        cmd = cmd,
        on_init = function(client, initialize_result)
            -- disable codelens for omnisharp because it makes it extremely slow
            client.server_capabilities.codeLensProvider = nil
            -- inlayHints are broken as well as of 1.39.10
            client.server_capabilities.inlayHintProvider = nil
            client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
        end,
        capabilities = register_cap(),
        handlers = {
            ["textDocument/definition"] = require("omnisharp_extended").handler,
        },
        root_dir = configs.root_dir(".sln") or configs.root_dir(".csproj"),
    }
end

return M
