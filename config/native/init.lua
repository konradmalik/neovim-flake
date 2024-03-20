-- caching needs to be first
require("konrad.loader")
-- colorscheme as soon as possible
require("konrad.colorscheme")

require("konrad.disable_builtin")

-- exrc (.nvim.lua)
vim.opt.exrc = true

-- map leader
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("konrad.globals")
