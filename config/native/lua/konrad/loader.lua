vim.loader.enable()
vim.api.nvim_create_user_command('CacheReset',
    function()
        vim.loader.reset()
        vim.cmd('KanagawaCompile')
    end,
    { desc = "Reset vim.loader cache", })
