local icons = require("konrad.icons")

-- keep foldcolumn on by default
vim.wo.foldcolumn = "1"
-- custom icons for foldcolumn
vim.o.fillchars = "eob: ,fold: ,foldopen:" ..
    icons.ui.FoldOpen .. ",foldsep:" .. icons.ui.Guide .. ",foldclose:" .. icons.ui.FoldClosed
vim.wo.foldmethod = "indent"
-- TODO this works well, but as of nvim 0.9.1 - if the current file is modified by another process, it will make the
-- whole neovim freeze
-- treesitter based folding
-- vim.wo.foldmethod = "expr"
-- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
-- needs to be set to some value to not fold everything at start
vim.wo.foldlevel = 5
-- disable folding at start completely
vim.wo.foldenable = false
