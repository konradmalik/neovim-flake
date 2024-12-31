local binaries = require("pde.binaries")

require("roslyn").setup({
    exe = binaries.roslyn_ls(),
    -- TODO after https://github.com/neovim/neovim/issues/31640, https://github.com/neovim/neovim/pull/31771
    -- config = vim.lsp.config.roslyn,
    config = require("pde.lsp.configs.roslyn"),
})
