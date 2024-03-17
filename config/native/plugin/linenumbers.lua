-- Make line numbers default
vim.opt.number = true
-- Relative line numbers
vim.opt.relativenumber = true

vim.api.nvim_create_user_command(
    "LineNumberToggle",
    function() vim.opt.relativenumber = not vim.opt.relativenumber end,
    {
        desc = "Enable/disable relative line numbers",
    }
)
