vim.o.shortmess = vim.o.shortmess .. "c"
vim.o.completeopt = "menuone,noinsert,noselect,popup,fuzzy"
vim.o.complete = "o,.,w,b,u"
vim.o.autocomplete = true
vim.o.autocompletedelay = 200

vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup("pde-completion-sanitizer", { clear = true }),
    callback = function(ev)
        if vim.bo[ev.buf].buftype ~= "" then vim.bo[ev.buf].autocomplete = false end
    end,
})

require("incomplete").setup()
