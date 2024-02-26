local binaries = require("konrad.binaries")
local fs = require("konrad.fs")
local runner = require("konrad.runner")

---@param command lsp.Command
---@return boolean
local function validate_command(command)
    if #command.arguments ~= 1 then
        vim.notify("unexpected arguments: " .. vim.inspect(command.arguments), vim.log.levels.ERROR)
        return false
    end

    return true
end

local function testRun(cwd, filter)
    local cmd = {
        "dotnet",
        "test",
        "--nologo",
        "--logger",
        "console;verbosity=detailed",
        "--filter",
        filter,
    }
    runner.run(cmd, { cwd = cwd })
end

local function getNameFromRange(range, bufnr)
    return vim.api.nvim_buf_get_text(
        bufnr,
        range["start"].line,
        range["start"].character,
        range["end"].line,
        range["end"].character,
        {}
    )[1]
end

---@type LspConfig
return {
    name = "roslyn",
    config = function()
        local solution = fs.find(".sln$")
        if not solution then
            vim.notify("cannot find solution file", vim.log.levels.WARN)
            return
        end

        local config = require("roslyn").config({
            cmd = binaries.roslyn_ls(),
            solution = solution,
        })
        if not config then return end

        local root_dir = config.root_dir
        config.commands = {
            ["dotnet.test.run"] = function(command, ctx)
                if not validate_command(command) then return end

                local range = command.arguments[1].range
                local name = getNameFromRange(range, ctx.bufnr)
                testRun(root_dir, name)
            end,
        }
        return config
    end,
}
