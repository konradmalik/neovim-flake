vim.o.foldcolumn = "auto"
vim.opt.fillchars = {
    eob = " ",
    fold = " ",
    foldopen = "",
    foldsep = "┊",
    foldclose = "",
}
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldtext = "v:lua.vim.treesitter.foldtext()"
-- when enabling, start with this level
vim.o.foldlevel = 1
vim.o.foldenable = false
