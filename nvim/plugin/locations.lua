---@param kind "file"|"line"|"pos"
local function copy_location(kind)
    local buf = vim.api.nvim_get_current_buf()
    local win = vim.api.nvim_get_current_win()

    local file = vim.api.nvim_buf_get_name(buf)
    if file == "" then return end

    local relpath = vim.fn.fnamemodify(file, ":.")
    local cursor = vim.api.nvim_win_get_cursor(win)

    local line = cursor[1]
    local col = cursor[2] + 1 -- 1-based for humans & tools

    local text
    if kind == "file" then
        text = relpath
    elseif kind == "line" then
        text = string.format("%s:%d", relpath, line)
    -- 'pos' (default)
    else
        text = string.format("%s:%d:%d", relpath, line, col)
    end

    -- System clipboard
    vim.fn.setreg("+", text)
    vim.fn.setreg('"', text) -- also unnamed register (nice UX)

    vim.notify("Copied: " .. text, vim.log.levels.INFO)
end

vim.keymap.set("n", "<leader>cf", function() copy_location("file") end, {
    desc = "[c]opy [f]ilepath to clipboard",
})

vim.keymap.set("n", "<leader>cl", function() copy_location("line") end, {
    desc = "[c]opy filepath:[l]ine to clipboard",
})

vim.keymap.set("n", "<leader>cp", function() copy_location("pos") end, {
    desc = "[c]opy filepath:line:col [p]osition to clipboard",
})
