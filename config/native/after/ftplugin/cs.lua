-- default is /*%s*/
vim.opt.commentstring = "// %s"

local dap = require("pde.dap")

dap.init("cs")
