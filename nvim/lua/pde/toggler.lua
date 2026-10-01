local toggles = {
    ["true"] = "false",
    ["always"] = "never",
    ["yes"] = "no",
    ["on"] = "off",
}

local lookup = {}
for a, b in pairs(toggles) do
    lookup[a] = b
    lookup[b] = a
end

--- Apply the casing of `original` to `word`.
---@param original string
---@param word string
---@return string
local function apply_case(original, word)
    if original == original:upper() then return word:upper() end
    if original:match("^%u") then return (word:gsub("^%l", string.upper)) end
    return word
end

--- The keyword under the cursor (not after it, unlike <cword>) and its replacement.
---@return {start: integer, finish: integer, text: string}? 0-based, end-exclusive byte columns
local function find_toggle()
    local m = vim.fn.matchstrpos(vim.api.nvim_get_current_line(), [[\k*\%]] .. vim.fn.col(".") .. [[c\k\+]])
    local word, start, finish = m[1], m[2], m[3]
    local match = lookup[word:lower()]
    if match then return { start = start, finish = finish, text = apply_case(word, match) } end
end

local function toggle()
    local t = find_toggle()
    if not t then return end
    local row = vim.fn.line(".") - 1
    vim.api.nvim_buf_set_text(0, row, t.start, row, t.finish, { t.text })
    vim.api.nvim_win_set_cursor(0, { row + 1, t.start + #t.text - 1 })
end

local M = {}

---Keys for an expr mapping: toggle the word under the cursor, or `fallback` when there is
---nothing to toggle. Goes through g@ so that `.` toggles the word under the cursor again.
---@param fallback string
---@return string
function M.toggle_or(fallback)
    if not find_toggle() then return fallback end
    vim.o.operatorfunc = toggle
    return "g@l"
end

return M
