-- default is /*%s*/
vim.opt.commentstring = "// %s"

local bufnr = vim.api.nvim_get_current_buf()
local dap = require("pde.dap")
local roslyn = require("pde.lsp.configs.roslyn_ls")

roslyn.init(bufnr)
dap.init("cs")
