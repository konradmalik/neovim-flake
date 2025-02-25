vim.o.foldcolumn = "1"
vim.opt.fillchars = {
    eob = " ",
    foldopen = "",
    foldsep = "┊",
    foldclose = "",
}
vim.o.foldmethod = "expr"
-- TODO: lua-based treesitter's foldexpr is unusable with fugitive's Git log command.
-- For some reason it takes 1-2 mins to open the log when this is set.
-- vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"
vim.o.foldtext = "v:lua.vim.treesitter.foldtext()"
-- when enabling, start with this level
vim.o.foldlevel = 99
vim.o.foldenable = true
