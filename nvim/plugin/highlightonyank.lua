local group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
    group = group,
    pattern = "*",
    callback = function() vim.hl.on_yank({ higroup = "Visual", timeout = 300 }) end,
})
