-- caching needs to be first
require("pde.loader")
-- colorscheme as soon as possible
require("pde.colorscheme")

-- exrc (.nvim.lua)
vim.opt.exrc = true

-- map leader
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("pde.globals")
