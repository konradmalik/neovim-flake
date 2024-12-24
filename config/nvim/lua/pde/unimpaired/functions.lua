-- based on https://github.com/tummetott/unimpaired.nvim
local M = {}

local get_current_wininfo = function() return vim.fn.getwininfo(vim.fn.win_getid())[1] end

local get_files = function(dir)
    local entries = vim.fn.split(vim.fn.glob(dir .. "/*"), "\n")
    local files = {}
    for _, entry in pairs(entries) do
        if vim.fn.isdirectory(entry) ~= 1 then
            table.insert(files, vim.fn.fnamemodify(entry, ":t"))
        end
    end
    if vim.tbl_isempty(files) then return end
    return files
end

local file_by_offset = function(offset)
    local dir = vim.fn.expand("%:p:h")
    local files = get_files(dir)
    if not files then return end
    local current = vim.fn.expand("%:t")
    if current == "" then
        if offset < 0 then return dir .. "/" .. files[1] end
        return dir .. "/" .. files[#files]
    else
        local index = vim.fn.index(files, current) + 1
        if index == 0 then return end
        index = index + offset
        if index < 1 then
            index = 1
        elseif index > #files then
            index = #files
        end
        return dir .. "/" .. files[index]
    end
end

M.previous_file = function()
    local wininfo = get_current_wininfo()
    if wininfo.loclist == 1 then
        vim.cmd("silent! lolder " .. vim.v.count1)
    elseif wininfo.quickfix == 1 then
        vim.cmd("silent! colder " .. vim.v.count1)
    else
        local file = file_by_offset(-vim.v.count1)
        if file then vim.cmd("edit " .. file) end
    end
end

M.next_file = function()
    local wininfo = get_current_wininfo()
    if wininfo.loclist == 1 then
        vim.cmd("silent! lnewer " .. vim.v.count1)
    elseif wininfo.quickfix == 1 then
        vim.cmd("silent! cnewer " .. vim.v.count1)
    else
        local file = file_by_offset(vim.v.count1)
        if file then vim.cmd("edit " .. file) end
    end
end

local qf_is_shown = function()
    return #vim.fn.filter(vim.fn.getwininfo(), "v:val.quickfix && !v:val.loclist") > 0
end

local ll_is_shown = function()
    return #vim.fn.filter(vim.fn.getwininfo(), "v:val.quickfix && v:val.loclist") > 0
end

M.toggle_qflist = function()
    if qf_is_shown() then
        vim.cmd("cclose")
    else
        vim.cmd("copen")
    end
end

M.toggle_llist = function()
    if ll_is_shown() then
        vim.cmd("lclose")
    else
        if not pcall(function() vim.cmd("lopen") end) then vim.notify("no location list") end
    end
end

M.opts_with_desc = function(desc) return { desc = "[unimpaired] " .. desc } end

return M
