-- fixed, not "auto": lsp folds arrive after the window switches to foldexpr,
-- and "auto" would make the column (and the text) jump while they fill in
vim.o.foldcolumn = "1"
vim.opt.fillchars = {
    eob = " ",
    foldopen = "",
    foldsep = "┊",
    foldclose = "",
    foldinner = " ",
}
vim.o.foldmethod = "indent"
-- when enabling, start with this level
vim.o.foldlevelstart = 99
vim.o.foldenable = true
