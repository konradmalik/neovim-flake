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
    local cmd = { task.kind }
    vim.list_extend(cmd, task.args.cargoArgs)
    vim.list_extend(cmd, task.args.cargoExtraArgs)
    if not vim.tbl_isempty(task.args.executableArgs) then
        table.insert(cmd, "--")
        vim.list_extend(cmd, task.args.executableArgs)
    end

    local cwd = task.args.workspaceRoot
    require("pde.runner").run(cmd, { cwd = cwd })
end

---@type vim.lsp.Config
return {
    ---@type lspconfig.settings.rust_analyzer
    settings = {
        ["rust-analyzer"] = {
            files = {
                exclude = {
                    "./.direnv/",
                    "./.git/",
                    "./.github/",
                    "./.gitlab/",
                    "./node_modules/",
                    "./ci/",
                    "./docs/",
                },
            },
            diagnostics = {
                experimental = {
                    enable = true,
                },
            },
        },
    },
    commands = {
        ["rust-analyzer.runSingle"] = runSingle,
    },
}
