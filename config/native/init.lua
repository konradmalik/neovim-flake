-- caching needs to be first
require("konrad.loader")

require("konrad.disable_builtin")

-- exrc (.nvim.lua)
vim.o.exrc = true

-- map leader
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("konrad.globals")
