local bufnr = vim.api.nvim_get_current_buf()

local dap = require("pde.dap")
local lsp = require("pde.lsp")

lsp.start(require("pde.lsp.configs.efm").setup("pyefm", { "black", "isort" }), { bufnr = bufnr })
lsp.start(require("pde.lsp.configs.pyright").config(bufnr), { bufnr = bufnr })
dap.init("python")
