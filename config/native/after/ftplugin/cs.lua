-- default is /*%s*/
vim.opt.commentstring = "// %s"

local bufnr = vim.api.nvim_get_current_buf()
local dap = require("pde.dap")
local lsp = require("pde.lsp")

lsp.init(require("pde.lsp.configs.roslyn_ls"), bufnr)
dap.init("cs")
