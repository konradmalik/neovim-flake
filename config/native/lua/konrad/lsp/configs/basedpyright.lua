-- https://detachhead.github.io/basedpyright

local binaries = require("konrad.binaries")
local configs = require("konrad.lsp.configs")

local name = "basedpyright"

local function organize_imports()
    local params = {
        command = "basedpyright.organizeimports",
        arguments = { vim.uri_from_bufnr(0) },
    }

    local clients = vim.lsp.get_clients({
        bufnr = vim.api.nvim_get_current_buf(),
        name = name,
    })
    for _, client in ipairs(clients) do
        client.request("workspace/executeCommand", params, nil, 0)
    end
end

local function set_python_path(path)
    local clients = vim.lsp.get_clients({
        bufnr = vim.api.nvim_get_current_buf(),
        name = name,
    })
    for _, client in ipairs(clients) do
        if client.settings then
            client.settings.python =
                vim.tbl_deep_extend("force", client.settings.python or {}, { pythonPath = path })
        else
            client.config.settings = vim.tbl_deep_extend(
                "force",
                client.config.settings,
                { python = { pythonPath = path } }
            )
        end
        client.notify("workspace/didChangeConfiguration", { settings = nil })
    end
end

return {
    config = function()
        ---@type vim.lsp.ClientConfig
        return {
            name = name,
            cmd = { binaries.basedpyright(), "--stdio" },
            root_dir = configs.root_dir({
                "pyproject.toml",
                "setup.py",
                "setup.cfg",
                "requirements.txt",
                "Pipfile",
                "pyrightconfig.json",
                ".git",
            }),
            settings = {
                basedpyright = {
                    analysis = {
                        autoSearchPaths = true,
                        useLibraryCodeForTypes = true,
                        diagnosticMode = "openFilesOnly",
                    },
                },
            },
            on_attach = function(_, bufnr)
                vim.api.nvim_buf_create_user_command(
                    bufnr,
                    "PyrightOrganizeImports",
                    function() organize_imports() end,
                    { desc = "[" .. name .. "] Organize imports" }
                )

                vim.api.nvim_buf_create_user_command(
                    bufnr,
                    "PyrightSetPythonPath",
                    function(args)
                        if args.nargs ~= 1 then
                            vim.notify(
                                "PyrightSetPythonPath required 1 argument",
                                vim.log.levels.ERROR
                            )
                            return
                        end
                        set_python_path(args.args)
                    end,
                    ---@type vim.api.keyset.user_command
                    {
                        nargs = 1,
                        complete = "file",
                        desc = "["
                            .. name
                            .. "] Reconfigure basedpyright with the provided python path",
                    }
                )

                vim.api.nvim_create_autocmd("LspDetach", {
                    group = vim.api.nvim_create_augroup(
                        "personal-lsp-" .. name .. "-buf-" .. bufnr,
                        { clear = true }
                    ),
                    buffer = bufnr,
                    callback = function()
                        vim.api.nvim_buf_del_user_command(bufnr, "PyrightOrganizeImports")
                        vim.api.nvim_buf_del_user_command(bufnr, "PyrightSetPythonPath")
                    end,
                })
            end,
        }
    end,
}
