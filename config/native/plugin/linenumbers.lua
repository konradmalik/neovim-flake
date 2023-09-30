vim.api.nvim_create_user_command("LineNumberToggle", function()
    vim.cmd([[set relativenumber!]])
end, {
    desc = "Enable/disable relative line numbers",
})
