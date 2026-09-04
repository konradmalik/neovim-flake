---@param desc string
---@return table
local function opts_with_desc(desc) return { desc = "[wArglist] " .. desc } end

---@param winid integer? if not provided, uses current
local function overview(winid)
    if vim.fn.argc(winid) > 0 then
        vim.cmd.args()
    else
        vim.notify("no arglist entries", vim.log.levels.INFO)
    end
end

---@param winid integer? if not provided, uses current
---@param idx integer go to arglist entry at this index
---@return boolean
local function navigate_idx(winid, idx)
    local arglen = vim.fn.argc(winid)
    if idx < 0 or idx >= arglen then
        vim.notify(idx .. " is out of range. Arglen: " .. arglen, vim.log.levels.INFO)
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

---@param lhs string
---@param f fun()
---@param desc string
local function map(lhs, f, desc)
    vim.keymap.set("n", lhs, function()
        f()
        overview(nil)
    end, opts_with_desc(desc))
end

map("<leader>aa", function() vim.cmd("$argadd | argdedupe") end, "append current buffer to the end")
map("<leader>ad", function() vim.cmd("argdelete %") end, "delete current buffer")
map("<leader>ac", function() vim.cmd("%argdelete") end, "clear all entries")
map("<leader>ao", function() end, "overview")

map("[a", function() navigate(nil, -vim.v.count1) end, "prev entry")
map("]a", function() navigate(nil, vim.v.count1) end, "next entry")

for i, key in ipairs({ "j", "k", "l", ";" }) do
    vim.keymap.set("n", "<leader>a" .. key, function()
        if navigate_idx(nil, i - 1) then overview(nil) end
    end, opts_with_desc("entry no. " .. i))
end
