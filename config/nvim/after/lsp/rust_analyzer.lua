local binaries = require("pde.binaries")
local runner = require("pde.runner")
local name = "rust_analyzer"

local function reload_workspace(bufnr)
    local clients = vim.lsp.get_clients({ name = name, bufnr = bufnr })
    for _, client in ipairs(clients) do
        vim.notify("Reloading Cargo Workspace")
        client:request("rust-analyzer/reloadWorkspace", nil, function(err)
            if err then error(tostring(err)) end
            vim.notify("Cargo workspace reloaded")
        end, 0)
    end
end

---@param command lsp.Command
---@return boolean
local function validate_command(command)
    if #command.arguments ~= 1 then
        vim.notify("unexpected arguments: " .. vim.inspect(command.arguments), vim.log.levels.ERROR)
        return false
    end

    ---@type table
    ---@diagnostic disable-next-line: assign-type-mismatch
    local task = command.arguments[1]
    if not task or task.kind ~= "cargo" then
        vim.notify("unexpected kind: " .. vim.inspect(task), vim.log.levels.ERROR)
        return false
    end

    return true
end

---@param command lsp.Command
local function runSingle(command)
    if not validate_command(command) then return end

    ---@type table
    ---@diagnostic disable-next-line: assign-type-mismatch
    local task = command.arguments[1]
    if not task then
        vim.notify("no command arguments", vim.log.levels.ERROR)
        return
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

    runner.run(vim.iter(cmd):flatten():totable(), { cwd = cwd })
end

---@type vim.lsp.Config
return {
    cmd = { binaries.rust_analyzer() },
    filetypes = { "rust" },
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
    },
    root_markers = { "Cargo.toml", "rust-project.json" },
    on_attach = function(_, buf)
        vim.api.nvim_buf_create_user_command(
            buf,
            "CargoReload",
            function() reload_workspace(buf) end,
            { desc = "[" .. name .. "] Reload current cargo workspace" }
        )

        vim.api.nvim_create_autocmd("LspDetach", {
            group = vim.api.nvim_create_augroup(
                "personal-lsp-" .. name .. "-buf-" .. buf,
                { clear = true }
            ),
            buffer = buf,
            callback = function() vim.api.nvim_buf_del_user_command(buf, "CargoReload") end,
        })
    end,
}
