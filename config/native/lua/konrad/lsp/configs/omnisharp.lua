-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#omnisharp

-- https://github.com/Hoffs/omnisharp-extended-lsp.nvim
vim.cmd("packadd omnisharp-extended-lsp.nvim")

local binaries = require("konrad.binaries")
local configs = require("konrad.lsp.configs")
local fs = require("konrad.fs")
local protocol = require("vim.lsp.protocol")
local ms = protocol.Methods

local M = {}

local root_dir = function() return configs.root_dir(".sln") or configs.root_dir(".csproj") end

local make_cmd = function()
    local cmd = {
        binaries.omnisharp(),
        "--zero-based-indices",
        "--hostPID",
        tostring(vim.fn.getpid()),
        "--encoding",
        "utf-8",
        "--languageserver",
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
    local root = root_dir()
    -- to avoid passing '-s nil' when attaching to $metadata$
    if root then
        table.insert(cmd, "-s")
        table.insert(cmd, root)
    end
    return cmd
end

-- disable documentHighlight in buffers that don't correspond to real files
local on_documentHighlight = vim.lsp.handlers[ms.textDocument_documentHighlight]

M.config = {
    -- this concrete name is needed by omnisharp_extended
    name = "omnisharp",
    cmd = make_cmd,
    on_init = function(client, _)
        -- disable codelens for omnisharp because it makes it extremely slow
        client.server_capabilities.codeLensProvider = nil
        -- client.server_capabilities.documentHighlightProvider = nil
        client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
    end,
    capabilities = {
        workspace = {
            workspaceFolders = false, -- https://github.com/OmniSharp/omnisharp-roslyn/issues/909
        },
    },
    handlers = {
        [ms.textDocument_definition] = function(err, result, context, config)
            return require("omnisharp_extended").handler(err, result, context, config)
        end,
        [ms.textDocument_documentHighlight] = vim.lsp.with(function(err, result, context, config)
            -- skip highlighting for files that do not exist physically
            if not fs.is_buf_readable_file(context.bufnr) then return end
            return on_documentHighlight(err, result, context, config)
        end, {}),
    },
    root_dir = root_dir,
}

return M
