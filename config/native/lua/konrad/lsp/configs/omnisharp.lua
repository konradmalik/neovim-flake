-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#omnisharp

-- https://github.com/Hoffs/omnisharp-extended-lsp.nvim
vim.cmd("packadd omnisharp-extended-lsp.nvim")

local binaries = require("konrad.binaries")
local configs = require("konrad.lsp.configs")

local M = {}

local root_dir = function()
    return configs.root_dir(".sln") or configs.root_dir(".csproj")
end

local make_cmd = function()
    return {
        binaries.omnisharp(),
        "--zero-based-indices",
        "--hostPID",
        tostring(vim.fn.getpid()),
        "--encoding",
        "utf-8",
        "--languageserver",
        "-s",
        root_dir(),
        "msbuild:loadProjectsOnDemand=true",
        "script:enabled=false",
        "DotNet:enablePackageRestore=false",
        "FormattingOptions:EnableEditorConfigSupport=true",
        "RoslynExtensionsOptions:analyzeOpenDocumentsOnly=true",
        "RoslynExtensionsOptions:enableAnalyzersSupport=true",
        "RoslynExtensionsOptions:enableDecompilationSupport=true",
        "RoslynExtensionsOptions:enableImportCompletion=true",
        "RoslynExtensionsOptions:inlayHintsOptions:enableForParameters=true",
        "RoslynExtensionsOptions:inlayHintsOptions:forLiteralParameters=true",
        "RoslynExtensionsOptions:inlayHintsOptions:forIndexerParameters=true",
        "RoslynExtensionsOptions:inlayHintsOptions:forObjectCreationParameters=true",
        "RoslynExtensionsOptions:inlayHintsOptions:forOtherParameters=true",
        "RoslynExtensionsOptions:inlayHintsOptions:suppressForParametersThatDifferOnlyBySuffix=false",
        "RoslynExtensionsOptions:inlayHintsOptions:suppressForParametersThatMatchMethodIntent=false",
        "RoslynExtensionsOptions:inlayHintsOptions:suppressForParametersThatMatchArgumentName=false",
        "RoslynExtensionsOptions:inlayHintsOptions:enableForTypes=true",
        "RoslynExtensionsOptions:inlayHintsOptions:forImplicitVariableTypes=true",
        "RoslynExtensionsOptions:inlayHintsOptions:forLambdaParameterTypes=true",
        "RoslynExtensionsOptions:inlayHintsOptions:forImplicitObjectCreation=true",
    }
end

M.config = {
    -- this concrete name is needed by omnisharp_extended
    name = "omnisharp",
    cmd = make_cmd,
    on_init = function(client, initialize_result)
        -- disable codelens for omnisharp because it makes it extremely slow
        client.server_capabilities.codeLensProvider = nil
        -- disable documentHighlight as it throws errors in buffers that don't correspond to real files
        -- like $metadata$ or fugitive
        client.server_capabilities.documentHighlightProvider = nil
        client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
    end,
    capabilities = {
        workspace = {
            workspaceFolders = false, -- https://github.com/OmniSharp/omnisharp-roslyn/issues/909
        },
    },
    handlers = {
        ["textDocument/definition"] = require("omnisharp_extended").handler,
    },
    root_dir = root_dir,
}

return M
