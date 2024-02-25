vim.opt.expandtab = false

local lsp = require("konrad.lsp")
lsp.init(require("konrad.lsp.configs.gopls"))
