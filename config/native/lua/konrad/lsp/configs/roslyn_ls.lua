local binaries = require("konrad.binaries")
local fs = require("konrad.fs")

local M = {}

function M.config()
    local solution = fs.find(".sln")
    if not solution then
        vim.notify("cannot find solution file", vim.log.levels.ERROR)
        return
    end

    return require("roslyn").config(binaries.roslyn_ls(), solution)
end

return M
