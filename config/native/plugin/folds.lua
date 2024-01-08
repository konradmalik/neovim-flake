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
-- TODO [0.9.5] treesitter foldexpr now does not freeze on external file modifications
-- but is unusable with fugitive's Git log command. For some reason it takes ~1 min to open the log
-- when this is set, so for now still use indent
vim.wo.foldmethod = "indent"
-- vim.wo.foldmethod = "expr"
-- vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.wo.foldtext = "v:lua.vim.treesitter.foldtext()"
-- when enabling, start with this level
vim.wo.foldlevel = 1
vim.wo.foldenable = false
