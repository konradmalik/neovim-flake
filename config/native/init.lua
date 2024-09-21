-- caching needs to be first
require("pde.loader")
-- colorscheme as soon as possible
require("pde.colorscheme")

-- exrc (.nvim.lua)
vim.o.exrc = true

-- map leader
vim.g.mapleader = vim.keycode("<Space>")

require("pde.globals")
