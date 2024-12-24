vim.o.shortmess = vim.o.shortmess .. "c"
vim.opt.completeopt = { "menuone", "popup", "noinsert", "noselect", "fuzzy" }

require("incomplete").setup()
