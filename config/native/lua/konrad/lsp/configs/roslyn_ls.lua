local binaries = require("konrad.binaries")
local fs = require("konrad.fs")

local M = {}

function M.config()
    local solution = fs.find(".sln$")
    if not solution then
        vim.notify("cannot find solution file", vim.log.levels.WARN)
        return
    end

    return require("roslyn").config({
        cmd = binaries.roslyn_ls(),
        solution = solution,
    })
end

return M
