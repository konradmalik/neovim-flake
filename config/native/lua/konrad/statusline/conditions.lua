local utils = require("konrad.statusline.utils")
local M = {}

function M.width_percent_below(n, thresh, is_winbar)
    local winwidth
    if vim.o.laststatus == 3 and not is_winbar then
        winwidth = vim.o.columns
    else
        winwidth = vim.api.nvim_win_get_width(utils.stwinnr())
    end

    return n / winwidth <= thresh
end

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

function M.buffer_matches(patterns, bufnr)
    bufnr = bufnr or 0
    for kind, pattern_list in pairs(patterns) do
        if pattern_list_matches(buf_matchers[kind](bufnr), pattern_list) then return true end
    end
    return false
end

return M
