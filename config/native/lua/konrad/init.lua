-- caching needs to be first
require("konrad.loader")

require("konrad.disable_builtin")

-- exrc (.nvim.lua), I use it a lot
vim.o.exrc = true

-- map leader
vim.keymap.set("n", "<Space>", "<Nop>", { silent = true, remap = false })
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("konrad.globals")
