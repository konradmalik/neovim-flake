-- caching needs to be first
require("pde.loader")
-- colorscheme as soon as possible
require("pde.colorscheme")

-- .nvim.lua
vim.o.exrc = true
vim.g.mapleader = vim.keycode("<Space>")

require("pde.globals")
