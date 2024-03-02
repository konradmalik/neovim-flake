local M = {}

---@return boolean
function M.is_activewin() return vim.api.nvim_get_current_win() == vim.g.statusline_winid end

local function pattern_list_matches(str, pattern_list)
    for _, pattern in ipairs(pattern_list) do
        if str:find(pattern) then return true end
    end
    return false
end

local buf_matchers = {
    filetype = function(bufnr) return vim.bo[bufnr].filetype end,
    buftype = function(bufnr) return vim.bo[bufnr].buftype end,
}

---@param patterns string[]
---@param bufnr integer
---@return boolean
function M.buffer_matches(patterns, bufnr)
    for kind, pattern_list in pairs(patterns) do
        if pattern_list_matches(buf_matchers[kind](bufnr), pattern_list) then return true end
    end
    return false
end

return M
