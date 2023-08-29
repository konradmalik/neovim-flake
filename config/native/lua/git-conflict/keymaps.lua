local KEYMAP_PREFIX = "[GitConflict]"
local search = require("git-conflict.search")

---@param bufnr integer
---@param position ConflictPosition
---@param replacement string[]
local replace_conflict = function(bufnr, position, replacement)
    vim.api.nvim_buf_set_lines(bufnr, position.current.range_start, position.incoming.range_end + 1, true, replacement)
end

---@param bufnr integer
---@param position ConflictPosition
local choose_current = function(bufnr, position)
    local choosen =
        vim.api.nvim_buf_get_lines(bufnr, position.current.content_start, position.current.content_end + 1, true)
    replace_conflict(bufnr, position, choosen)
end

---@param bufnr integer
---@param position ConflictPosition
local choose_incoming = function(bufnr, position)
    local choosen =
        vim.api.nvim_buf_get_lines(bufnr, position.incoming.content_start, position.incoming.content_end + 1, true)
    replace_conflict(bufnr, position, choosen)
end

---@param bufnr integer
---@param position ConflictPosition
local choose_both = function(bufnr, position)
    local current =
        vim.api.nvim_buf_get_lines(bufnr, position.current.content_start, position.current.content_end + 1, true)
    local incoming =
        vim.api.nvim_buf_get_lines(bufnr, position.incoming.content_start, position.incoming.content_end + 1, true)
    local choosen = {}
    vim.list_extend(choosen, current)
    vim.list_extend(choosen, incoming)
    replace_conflict(bufnr, position, choosen)
end

---@param bufnr integer
---@param position ConflictPosition
local choose_none = function(bufnr, position)
    replace_conflict(bufnr, position, {})
end

---@param bufnr integer
---@param positions ConflictPosition[]
---@param action function
local process_current_conflict = function(bufnr, positions, action)
    local line1, _ = unpack(vim.api.nvim_win_get_cursor(0))
    -- we expect lines to be 0-indexed
    local line = line1 - 1
    for _, position in ipairs(positions) do
        if position.current.range_start <= line and position.incoming.range_end >= line then
            action(bufnr, position)
            return
        end
    end
    vim.notify("no conflict at that line")
end

local M = {}

---@param conflict_marker string
M.set_global_keymaps = function(conflict_marker)
    local opts_with_desc = function(desc)
        return { noremap = true, silent = true, desc = KEYMAP_PREFIX .. " " .. desc }
    end

    vim.keymap.set("n", "]x", function()
        vim.fn.search(conflict_marker, "w")
    end, opts_with_desc("Next Conflict"))

    vim.keymap.set("n", "[x", function()
        vim.fn.search(conflict_marker, "w")
    end, opts_with_desc("Previous Conflict"))

    vim.keymap.set("n", "<leader>xq", function()
        search.setqflist()
    end, opts_with_desc("Fill quickfix list with all conflicts"))
end

---@param bufnr integer
---@param positions ConflictPosition[]
---@param callback function
M.set_buf_keymaps = function(bufnr, positions, callback)
    local opts_with_desc = function(desc)
        return { noremap = true, silent = true, buffer = bufnr, desc = KEYMAP_PREFIX .. " " .. desc }
    end

    vim.keymap.set("n", "<leader>co", function()
        process_current_conflict(bufnr, positions, choose_current)
        callback(bufnr)
    end, opts_with_desc("Choose ours (current/HEAD/LOCAL)"))

    vim.keymap.set("n", "<leader>ct", function()
        process_current_conflict(bufnr, positions, choose_incoming)
        callback(bufnr)
    end, opts_with_desc("Choose theirs (incoming/REMOTE)"))

    vim.keymap.set("n", "<leader>cb", function()
        process_current_conflict(bufnr, positions, choose_both)
        callback(bufnr)
    end, opts_with_desc("Choose both"))

    vim.keymap.set("n", "<leader>cn", function()
        process_current_conflict(bufnr, positions, choose_none)
        callback(bufnr)
    end, opts_with_desc("Choose none"))
end

M.del_buf_keymaps = function(bufnr)
    local mode = "n"
    local keymaps = vim.api.nvim_buf_get_keymap(bufnr, mode)
    for _, keymap in ipairs(keymaps) do
        if keymap.desc then
            if vim.startswith(keymap.desc, KEYMAP_PREFIX) then
                vim.api.nvim_buf_del_keymap(bufnr, mode, keymap.lhs)
            end
        end
    end
end

return M
