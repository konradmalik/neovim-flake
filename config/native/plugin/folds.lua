vim.o.foldcolumn = "auto"
vim.opt.fillchars = {
    eob = " ",
    fold = " ",
    foldopen = "",
    foldsep = "┊",
    foldclose = "",
}
vim.o.foldmethod = "expr"
-- TODO: lua-based treesitter's foldexpr is unusable with fugitive's Git log command.
-- For some reason it takes 1-2 mins to open the log when this is set.
-- vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"
vim.o.foldtext = ""
-- when enabling, start with this level
vim.o.foldlevel = 1
vim.o.foldenable = false
