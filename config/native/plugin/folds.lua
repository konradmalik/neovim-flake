local icons = {
    FoldClosed = "",
    FoldOpen = "",
    Guide = "┊",
}

vim.opt.foldcolumn = "auto"
vim.opt.fillchars = {
    eob = " ",
    fold = " ",
    foldopen = icons.FoldOpen,
    foldsep = icons.Guide,
    foldclose = icons.FoldClosed,
}
vim.opt.foldmethod = "expr"
-- TODO: lua-based treesitter's foldexpr is unusable with fugitive's Git log command.
-- For some reason it takes 1-2 mins to open the log when this is set.
-- vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldtext = ""
-- when enabling, start with this level
vim.opt.foldlevel = 1
vim.opt.foldenable = false
