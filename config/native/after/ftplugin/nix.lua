vim.opt.shiftwidth = 2

local lsp = require("konrad.lsp")
lsp.init(require("konrad.lsp.configs.nil_ls"))
