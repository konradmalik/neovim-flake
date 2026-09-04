local default_max_line_length = 120

local function get_max_line_length()
    local ed = vim.b.editorconfig or {}
    return ed.max_line_length or default_max_line_length
end

vim.api.nvim_create_user_command("ColorcolumnToggle", function()
    if vim.wo[0][0].colorcolumn == "" then
        local size = get_max_line_length()
        vim.notify("enabling colorcolumn as: " .. tostring(size), vim.log.levels.INFO)
        vim.wo[0][0].colorcolumn = tostring(size)
    else
        vim.notify("disabling colorcolumn")
        vim.wo[0][0].colorcolumn = ""
    end
end, {
    desc = "Enable/disable colorcolumn in the current window. Respects editorconfig.",
})
