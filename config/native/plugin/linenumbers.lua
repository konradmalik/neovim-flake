-- Make line numbers default
vim.opt.number = true
-- Relative line numbers
vim.opt.relativenumber = true

vim.api.nvim_create_user_command(
    "LineNumberToggle",
    ---@diagnostic disable-next-line: undefined-field
    function() vim.opt.relativenumber = not vim.opt.relativenumber:get() end,
    {
        desc = "Enable/disable relative line numbers",
    }
)
