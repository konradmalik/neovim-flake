local group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd({ "TextYankPost", "TextPutPost" }, {
    group = group,
    callback = function() vim.hl.hl_op({ higroup = "Visual", timeout = 300 }) end,
})
