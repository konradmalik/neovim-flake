vim.o.wildmode = "noselect:lastused,full"

local cmd = { "fd", "--type", "file", "--hidden", "--exclude", ".git" }

local function candidates()
    local res = vim.system(cmd, { text = true }):wait()
    return res.code == 0 and vim.split(res.stdout, "\n", { trimempty = true }) or {}
end

function _G.fuzzy_findfunc(cmdarg, _)
    local files = candidates()
    if cmdarg == "" then return files end
    return vim.fn.matchfuzzy(files, cmdarg)
end

vim.o.findfunc = "v:lua.fuzzy_findfunc"
