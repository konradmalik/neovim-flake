-- Make line numbers default
vim.o.number = true
-- Relative line numbers
vim.o.relativenumber = true

vim.api.nvim_create_user_command(
    "LineNumberToggle",
    ---@diagnostic disable-next-line: undefined-field
    function() vim.o.relativenumber = not vim.o.relativenumber end,
    {
        desc = "Enable/disable relative line numbers",
    }
)
