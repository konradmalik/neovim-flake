local default_max_line_length = 120

local function get_max_line_length()
    local ed = vim.b.editorconfig or {}
    return ed.max_line_length or default_max_line_length
end

vim.api.nvim_create_user_command("ColorcolumnToggle", function()
    local current = vim.o.colorcolumn
    if current == "" then
        local size = get_max_line_length()
        print("enabling colorcolumn as: " .. tostring(size))
        vim.o.colorcolumn = tostring(size)
    else
        print("disabling colorcolumn")
        vim.o.colorcolumn = ""
    end
end, {
    desc = "Enable/disable colorcolumn. Respects editorconfig.",
})
