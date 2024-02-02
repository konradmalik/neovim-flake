-- NOTE: this is a vastly simplified https://github.com/jmederosalvarado/roslyn.nvim
local hacks = require("roslyn.hacks")
local roslyn_lsp_rpc = require("roslyn.lsp")

local M = {}

---Creates a new Roslyn lsp server configuration
---Should be passed to eg. start_client
---@param cmd string
---@param solution string must be a sln file
---@return lsp.ClientConfig?
function M.config(cmd, solution)
    if solution:sub(-4) ~= ".sln" then
        vim.notify(
            "Roslyn target should be a `.sln` file but was: " .. solution,
            vim.log.levels.ERROR
        )
        return
    end

    local server_args = {
        "--logLevel=Information",
        "--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.get_log_path()),
    }

    return {
        name = "roslyn",
        cmd = hacks.wrap_server_cmd(roslyn_lsp_rpc.start_uds(cmd, server_args)),
        root_dir = vim.fs.dirname(solution),
        on_init = function(client)
            vim.notify(
                "Roslyn client initialized for target " .. vim.fn.fnamemodify(solution, ":~:."),
                vim.log.levels.INFO
            )

            client.notify("solution/open", {
                ["solution"] = vim.uri_from_fname(solution),
            })
        end,
        handlers = {
            [vim.lsp.protocol.Methods.textDocument_publishDiagnostics] = hacks.with_fixed_diagnostics_tags(
                vim.lsp.handlers[vim.lsp.protocol.Methods.textDocument_publishDiagnostics]
            ),
            [vim.lsp.protocol.Methods.textDocument_diagnostic] = hacks.with_fixed_diagnostics_tags(
                vim.lsp.handlers[vim.lsp.protocol.Methods.textDocument_diagnostic]
            ),
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
