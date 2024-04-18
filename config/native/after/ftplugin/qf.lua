local is_locationlist = function()
    local info = vim.fn.getwininfo(vim.fn.win_getid())[1]
    return info["loclist"] == 1 and info["quickfix"] == 1
end

local del_item = function()
    local items
    if is_locationlist() then
        items = vim.fn.getloclist(0)
    else
        items = vim.fn.getqflist()
    end
    if #items == 0 then return end

    local line = vim.fn.line(".")
    table.remove(items, line)
    if is_locationlist() then
        vim.fn.setloclist(0, items)
    else
        vim.fn.setqflist(items)
    end

    local new_line = line < #items and line or math.max(line - 1, 1)
    vim.api.nvim_win_set_cursor(0, { new_line, 0 })
end

local older_list = function()
    if is_locationlist() then
        vim.cmd("lolder")
    else
        vim.cmd("colder")
    end
end

local newer_list = function()
    if is_locationlist() then
        vim.cmd("lnewer")
    else
        vim.cmd("cnewer")
    end
end

local function opts_with_desc(desc) return { silent = true, buffer = true, desc = desc } end
vim.keymap.set("n", "dd", del_item, opts_with_desc("Remove entry from the list"))
vim.keymap.set("v", "d", del_item, opts_with_desc("Remove entry from the list"))
vim.keymap.set("n", "u", older_list, opts_with_desc("Go to older list"))
vim.keymap.set("n", "<C-r>", newer_list, opts_with_desc("Go to newer list"))
