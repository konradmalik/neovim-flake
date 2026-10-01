-- based on https://github.com/tummetott/unimpaired.nvim
---@class pde.unimpaired
local M = {}

---Path of the file `offset` entries away from the current one in its directory, sorted by
---name and clamped at the ends. nil when there is nowhere to go.
---@param offset integer
---@return string?
local function sibling_file(offset)
    if vim.bo.buftype ~= "" then return end
    local path = vim.api.nvim_buf_get_name(0)
    local dir = path == "" and vim.fn.getcwd() or vim.fs.dirname(path)

    -- only files on the side we're heading to, so this also works when the current
    -- file isn't on disk (unnamed, or not written yet)
    local files = {}
    for name in vim.fs.dir(dir) do
        local file = vim.fs.joinpath(dir, name)
        local ahead = offset > 0 and file > path or offset < 0 and file < path
        -- fs_stat follows symlinks; skips directories, broken links and special files
        if ahead and (vim.uv.fs_stat(file) or {}).type == "file" then table.insert(files, file) end
    end
    table.sort(files)

    if offset > 0 then return files[math.min(offset, #files)] end
    return files[math.max(1, #files + offset + 1)]
end

---In a quickfix/location list window: go to an older/newer list. Elsewhere: go to a sibling file.
---@param direction 1|-1
local function step(direction)
    local count = vim.v.count1
    local wintype = vim.fn.win_gettype()
    if wintype == "quickfix" or wintype == "loclist" then
        local cmd = (wintype == "loclist" and "l" or "c") .. (direction > 0 and "newer" or "older")
        vim.cmd({ cmd = cmd, count = count, mods = { emsg_silent = true } })
        return
    end
    local file = sibling_file(direction * count)
    if file then vim.cmd.edit(vim.fn.fnameescape(file)) end
end

M.previous_file = function() step(-1) end
M.next_file = function() step(1) end

M.toggle_qflist = function()
    if vim.fn.getqflist({ winid = 0 }).winid ~= 0 then
        vim.cmd.cclose()
    else
        vim.cmd.copen()
    end
end

M.toggle_llist = function()
    if vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 then
        vim.cmd.lclose()
    elseif not pcall(vim.cmd.lopen) then
        vim.notify("no location list")
    end
end

return M
