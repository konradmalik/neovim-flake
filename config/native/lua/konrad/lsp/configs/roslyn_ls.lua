local binaries = require("konrad.binaries")
local configs = require("konrad.lsp.configs")
local fs = require("konrad.fs")

vim.cmd("packadd roslyn.nvim")
local roslyn = require("roslyn")

local solution = fs.find(".sln")
if not solution then
    vim.notify("cannot find solution file", vim.log.levels.ERROR)
    return
end

local roslynconfig = roslyn.config(binaries.roslyn_ls(), solution)
roslynconfig.cmd = function() return roslynconfig.cmd end
roslynconfig.root_dir = configs.root_dir(".sln")
return {
    config = roslynconfig,
}
