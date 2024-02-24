local binaries = require("konrad.binaries")
local configs = require("konrad.lsp.configs")
local runner = require("konrad.runner")
local name = "rust_analyzer"

local function reload_workspace(bufnr)
    local clients = vim.lsp.get_clients({ name = name, bufnr = bufnr })
    for _, client in ipairs(clients) do
        vim.notify("Reloading Cargo Workspace")
        client.request("rust-analyzer/reloadWorkspace", nil, function(err)
            if err then error(tostring(err)) end
            vim.notify("Cargo workspace reloaded")
        end, 0)
    end
end

local function runSingle(args)
    if #args.arguments ~= 1 then
        vim.notify("unexpected arguments: " .. vim.inspect(args.arguments), vim.log.levels.ERROR)
    end

    local task = args.arguments[1]
    if task.kind ~= "cargo" then
        vim.notify("unexpected kind: " .. task.kind, vim.log.levels.ERROR)
    end

    local cmd = {
        task.kind,
        task.args.cargoArgs,
        task.args.cargoExtraArgs,
    }
    if not vim.tbl_isempty(task.args.executableArgs) then
        table.insert(cmd, { "--" })
        table.insert(cmd, task.args.executableArgs)
    end

    local cwd = task.args.workspaceRoot

    runner.run(vim.tbl_flatten(cmd), { cwd = cwd })
end

local M = {}

--TODO use this
M.buf_commands = {
    CargoReload = {
        cmd = function() reload_workspace(0) end,
        opts = { desc = "[rust-analyzer] Reload current cargo workspace" },
    },
}

function M.config()
    return {
        name = name,
        cmd = { binaries.rust_analyzer() },
        capabilities = {
            experimental = {
                serverStatusNotification = true,
            },
        },
        settings = {
            ["rust-analyzer"] = {
                rustfmt = {
                    overrideCommand = {
                        binaries.rustfmt(),
                        "--edition",
                        "2021",
                        "--",
                    },
                },
                files = {
                    excludeDirs = {
                        "./.direnv/",
                        "./.git/",
                        "./.github/",
                        "./.gitlab/",
                        "./node_modules/",
                        "./ci/",
                        "./docs/",
                    },
                },
                checkOnSave = {
                    enable = true,
                },
                diagnostics = {
                    enable = true,
                    experimental = {
                        enable = true,
                    },
                },
            },
        },
        commands = {
            ["rust-analyzer.runSingle"] = runSingle,
            ["rust-analyzer.debugSingle"] = function(args) P(args) end,
            ["rust-analyzer.showReferences"] = function(args) P(args) end,
            ["rust-analyzer.gotoLocation"] = function(args) P(args) end,
        },
        root_dir = configs.root_dir({ "Cargo.toml", "rust-project.json" }),
    }
end
return M
