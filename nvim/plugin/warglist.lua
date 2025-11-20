---@param desc string
---@return table
local function opts_with_desc(desc) return { desc = "[wArglist] " .. desc } end

---@param winid integer? if not provided, uses current
local function overview(winid)
    if vim.fn.argc(winid) > 0 then
        vim.cmd.args()
    else
        print("no arglist entries")
    end
end

---@param winid integer? if not provided, uses current
---@param idx integer? go to arglist entry at index. Go to current index if not provided
---@return boolean
local function navigate_idx(winid, idx)
    local arglen = vim.fn.argc(winid)
    if idx < 0 or idx >= arglen then
        print(idx .. " is out of range. Arglen: " .. arglen)
        return false
    end
    vim.cmd((idx + 1) .. "argument")
    return true
end

---@param winid integer? if not provided, uses current
---@param count integer how many steps to perform
---@return boolean
local function navigate(winid, count)
    local arglen = vim.fn.argc(winid)
    if arglen == 0 then return false end

    local nextidx = (vim.fn.argidx() + count) % arglen
    while nextidx < 0 do
        nextidx = nextidx + arglen
    end
    return navigate_idx(winid, nextidx)
end

local function append_curr() vim.cmd("$argadd | argdedupe") end
local function delete_curr() vim.cmd("argdelete %") end
local function clear_all() vim.cmd("%argdelete") end

vim.keymap.set("n", "<leader>aa", function()
    append_curr()
    local winid = nil
    overview(winid)
end, opts_with_desc("append current buffer to the end"))
vim.keymap.set("n", "<leader>ad", function()
    delete_curr()
    local winid = nil
    overview(winid)
end, opts_with_desc("delete current buffer"))
vim.keymap.set("n", "<leader>ac", function()
    clear_all()
    local winid = nil
    overview(winid)
end, opts_with_desc("clear all entries"))
vim.keymap.set("n", "<leader>ao", overview, opts_with_desc("overview"))
vim.keymap.set("n", "[a", function()
    local winid = nil
    navigate(winid, vim.v.count1 * -1)
    overview(winid)
end, opts_with_desc("prev entry"))
vim.keymap.set("n", "]a", function()
    local winid = nil
    navigate(winid, vim.v.count1)
    overview(winid)
end, opts_with_desc("next entry"))
vim.keymap.set("n", "<leader>aj", function()
    local winid = nil
    if navigate_idx(winid, 0) then overview(winid) end
end, opts_with_desc("1st entry"))
vim.keymap.set("n", "<leader>ak", function()
    local winid = nil
    if navigate_idx(winid, 1) then overview(winid) end
end, opts_with_desc("2nd entry"))
vim.keymap.set("n", "<leader>al", function()
    local winid = nil
    if navigate_idx(winid, 2) then overview(winid) end
end, opts_with_desc("3rd entry"))
vim.keymap.set("n", "<leader>a;", function()
    local winid = nil
    if navigate_idx(winid, 3) then overview(winid) end
end, opts_with_desc("4th entry"))
