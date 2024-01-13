local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = vim.highlight.on_yank,
    group = highlight_group,
    pattern = "*",
})
