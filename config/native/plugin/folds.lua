local icons = require("konrad.icons")

-- keep foldcolumn on by default
vim.opt.foldcolumn = "auto"
-- custom icons for foldcolumn
vim.opt.fillchars = {
    eob = " ",
    fold = " ",
    foldopen = icons.ui.FoldOpen,
    foldsep = icons.ui.Guide,
    foldclose = icons.ui.FoldClosed,
}
vim.opt.foldmethod = "expr"
-- TODO lua-based treesitter's foldexpr is unusable with fugitive's Git log command.
-- For some reason it takes 1-2 mins to open the log when this is set.
-- vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldtext = "v:lua.vim.treesitter.foldtext()"
-- when enabling, start with this level
vim.opt.foldlevel = 1
vim.opt.foldenable = false
