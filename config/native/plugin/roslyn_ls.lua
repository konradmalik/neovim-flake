require("lz.n").load({
    "roslyn.nvim",
    ft = "cs",
    after = function()
        local binaries = require("pde.binaries")

        require("roslyn").setup({
            exe = binaries.roslyn_ls(),
            -- TODO after https://github.com/neovim/neovim/issues/31640
            -- config = vim.lsp.config.roslyn,
            config = require("pde.lsp.configs.roslyn"),
        })
    end,
})
