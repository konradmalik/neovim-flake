-- NOTE: whole module based on https://github.com/seblj/roslyn.nvim
local M = {}

---@class RoslynConfig
---@field pipe_name string
---@field solution string
--- Set `filewatching` to false if you experience performance problems.
--- Defaults to true, since turning it off is a hack.
--- If you notice that the server is _super_ slow, it is probably because of file watching
--- I noticed that neovim became super unresponsive on some large codebases, and that was because
--- it schedules the file watching on the event loop.
--- This issue went away by disabling that capability. However, roslyn will fallback to its own
--- file watching, which can make the server super slow to initialize.
--- Setting this option to false will indicate to the server that neovim will do the file watching.
--- However, in `hacks.lua` I will also just don't start off any watchers, which seems to make the server
--- a lot faster to initialize.
---@field filewatching boolean

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

    local enableFilewatching = config.filewatching or true

    return {
        name = "roslyn",
        cmd = vim.lsp.rpc.connect(config.pipe_name),
        root_dir = vim.fs.dirname(solution),
        on_init = function(client)
            vim.notify(
                "Roslyn client initialized for target " .. vim.fn.fnamemodify(solution, ":~:."),
                vim.log.levels.INFO
            )

            client.notify("solution/open", {
                ["solution"] = vim.uri_from_fname(solution),
            })

            local commands = require("roslyn.commands")
            commands.fix_all_code_action(client)
            commands.nested_code_action(client)
        end,
        handlers = {
            ["client/registerCapability"] = require("roslyn.hacks").with_filtered_watchers(
                vim.lsp.handlers["client/registerCapability"],
                enableFilewatching
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
            ["workspace/_roslyn_projectNeedsRestore"] = function(_, result, ctx)
                local client = vim.lsp.get_client_by_id(ctx.client_id)
                assert(client)

                client.request("workspace/_roslyn_restore", result, function(err, response)
                    if err then vim.notify(err.message, vim.log.levels.ERROR) end
                    if response then
                        for _, v in ipairs(response) do
                            vim.notify(v.message)
                        end
                    end
                end)

                return vim.NIL
            end,
        },
        capabilities = {
            workspace = {
                didChangeWatchedFiles = {
                    dynamicRegistration = not enableFilewatching,
                },
            },
            textDocument = {
                diagnostic = {
                    dynamicRegistration = true,
                },
            },
        },
    }
end

return M
