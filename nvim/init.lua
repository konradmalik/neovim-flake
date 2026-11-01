-- caching needs to be first
vim.loader.enable()
-- before anything loads plugins
require("pde.devplugins")
-- colorscheme as soon as possible
vim.cmd.colorscheme("kanagawa")

-- .nvim.lua
vim.o.exrc = true
vim.g.mapleader = " "
vim.g.maplocalleader = ","
