-- NOTE: whole module based on https://github.com/seblj/roslyn.nvim
local hacks = require("roslyn.hacks")

local M = {}

---@class RoslynConfig
---@field pipe_name string
---@field solution string

---Creates a new Roslyn LSP server configuration
---Should be passed to eg. start_client
---@param config RoslynConfig
---@return vim.lsp.ClientConfig?
function M.config(config)
    local solution = config.solution
    if solution:sub(-4) ~= ".sln" then
        vim.notify(
            "Roslyn target should be a `.sln` file but was: " .. solution,
            vim.log.levels.WARN
        )
        return
    end

    return {
        name = "roslyn",
        cmd = vim.lsp.rpc.connect(config.pipe_name),
        root_dir = vim.fs.dirname(solution),
        on_init = function(client)
            local commands = require("roslyn.commands")
            commands.fix_all_code_action(client)
            commands.nested_code_action(client)

            vim.notify(
                "Roslyn client initialized for target " .. vim.fn.fnamemodify(solution, ":~:."),
                vim.log.levels.INFO
            )

            client.notify("solution/open", {
                ["solution"] = vim.uri_from_fname(solution),
            })
        end,
        handlers = {
            [vim.lsp.protocol.Methods.client_registerCapability] = hacks.with_filtered_watchers(
                vim.lsp.handlers[vim.lsp.protocol.Methods.client_registerCapability]
            ),
            ["workspace/projectInitializationComplete"] = function()
                vim.notify("Roslyn project initialization complete", vim.log.levels.INFO)
            end,
            ["workspace/_roslyn_projectHasUnresolvedDependencies"] = function()
                vim.notify(
                    "Detected missing dependencies. Run dotnet restore command.",
                    vim.log.levels.ERROR
                )
                return vim.NIL
            end,
        },
    }
end

return M
