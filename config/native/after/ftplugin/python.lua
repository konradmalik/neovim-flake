local bufnr = vim.api.nvim_get_current_buf()

local dap = require("pde.dap")
local lsp = require("pde.lsp")

lsp.init(require("pde.lsp.configs.efm").setup("pyefm", { "black", "isort" }), bufnr)
lsp.init(require("pde.lsp.configs.pyright").config(), bufnr)
dap.init("python")
