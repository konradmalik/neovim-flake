-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#omnisharp

-- https://github.com/Hoffs/omnisharp-extended-lsp.nvim
vim.cmd("packadd omnisharp-extended-lsp.nvim")

local fs = require("konrad.fs")
local binaries = require("konrad.binaries")
local configs = require("konrad.lsp.configs")

local M = {}

local make_cmd = function()
    local cmd
    -- something's broken with omnisharp script in nix when dotnet is in path...
    local local_dotnet = fs.path_executable("dotnet")
    if local_dotnet then
        cmd = { local_dotnet, binaries.omnisharp_dll() }
    else
        cmd = { binaries.omnisharp() }
    end
    vim.list_extend(cmd, {
        "-z",
        "--hostPID",
        tostring(vim.fn.getpid()),
        "--encoding",
        "utf-8",
        "--languageserver",
        "DotNet:enablePackageRestore=false",
        "FormattingOptions:EnableEditorConfigSupport=true",
        "FormattingOptions:OrganizeImports=true",
        "MsBuild:LoadProjectsOnDemand=true",
        "RoslynExtensionsOptions:EnableAnalyzersSupport=true",
        "RoslynExtensionsOptions:EnableImportCompletion=true",
        "RoslynExtensionsOptions:AnalyzeOpenDocumentsOnly=true",
    })

    return cmd
end

M.config = {
    -- this concrete name is needed by omnisharp_extended
    name = "omnisharp",
    cmd = make_cmd,
    on_init = function(client, initialize_result)
        -- disable codelens for omnisharp because it makes it extremely slow
        client.server_capabilities.codeLensProvider = nil
        -- inlayHints are broken as well as of 1.39.10
        client.server_capabilities.inlayHintProvider = nil
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
    root_dir = function()
        return configs.root_dir(".sln") or configs.root_dir(".csproj")
    end,
}

return M
