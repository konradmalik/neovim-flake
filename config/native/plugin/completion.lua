vim.opt.shortmess:append("c")
vim.opt.completeopt = { "menuone", "popup", "noinsert", "noselect", "fuzzy" }

local incomplete = require("pde.incomplete")
incomplete.setup()
