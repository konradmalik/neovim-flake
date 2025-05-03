vim.o.shortmess = vim.o.shortmess .. "c"
vim.o.completeopt = "menuone,noinsert,noselect,popup,fuzzy"

require("incomplete").setup()
