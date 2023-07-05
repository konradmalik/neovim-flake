vim.api.nvim_create_autocmd('UiEnter', {
    callback = function() vim.cmd('packadd vim-fugitive') end,
    desc = "Lazily initialize vim-fugitive",
    once = true,
})
