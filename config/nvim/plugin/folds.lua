vim.o.foldcolumn = "1"
vim.opt.fillchars = {
    eob = " ",
    foldopen = "",
    foldsep = "┊",
    foldclose = "",
}
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldtext = "v:lua.vim.treesitter.foldtext()"
-- when enabling, start with this level
vim.o.foldlevel = 99
vim.o.foldenable = true
