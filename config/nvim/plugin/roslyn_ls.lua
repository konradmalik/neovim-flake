local binaries = require("pde.binaries")

require("roslyn").setup({
    exe = binaries.roslyn_ls(),
    config = vim.lsp.config.roslyn,
})
