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
-- TODO [0.9.5] treesitter foldexpr now does not freeze on external file modifications
-- but is unusable with fugitive's Git log command. For some reason it takes ~1 min to open the log
-- when this is set, so for now still use indent
vim.opt.foldmethod = "indent"
-- vim.opt.foldmethod = "expr"
-- vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldtext = "v:lua.vim.treesitter.foldtext()"
-- when enabling, start with this level
vim.opt.foldlevel = 1
vim.opt.foldenable = false
