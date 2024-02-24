local binaries = require("konrad.binaries")
local configs = require("konrad.lsp.configs")
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
            ["rust-analyzer.runSingle"] = function(args) P(args) end,
            ["rust-analyzer.debugSingle"] = function(args) P(args) end,
            ["rust-analyzer.showReferences"] = function(args) P(args) end,
            ["rust-analyzer.gotoLocation"] = function(args) P(args) end,
        },
        root_dir = configs.root_dir({ "Cargo.toml", "rust-project.json" }),
    }
end
return M
