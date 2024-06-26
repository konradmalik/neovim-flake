-- default is /*%s*/
vim.opt.commentstring = "// %s"

local bufnr = vim.api.nvim_get_current_buf()
local dap = require("pde.dap")
local lsp = require("pde.lsp")
local roslyn = require("pde.lsp.configs.roslyn_ls")

roslyn.wrap(function(lsp_config) lsp.init(lsp_config, bufnr) end)
dap.init("cs")
