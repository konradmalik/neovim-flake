local icons = require("konrad.icons")

-- keep foldcolumn on by default
vim.wo.foldcolumn = "auto"
-- custom icons for foldcolumn
vim.o.fillchars = "eob: ,fold: ,foldopen:"
    .. icons.ui.FoldOpen
    .. ",foldsep:"
    .. icons.ui.Guide
    .. ",foldclose:"
    .. icons.ui.FoldClosed
vim.wo.foldmethod = "expr"
vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.wo.foldtext = "v:lua.vim.treesitter.foldtext()"
-- when enabling, start with this level
vim.wo.foldlevel = 1
vim.wo.foldenable = false
