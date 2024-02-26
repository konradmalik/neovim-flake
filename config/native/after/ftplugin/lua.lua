local bufnr = vim.api.nvim_get_current_buf()

local efm = require("konrad.lsp.efm")
local lsp = require("konrad.lsp")

lsp.init(efm.build_config("stylua", { "stylua" }), bufnr)
lsp.init(require("konrad.lsp.configs.lua_ls"), bufnr)
