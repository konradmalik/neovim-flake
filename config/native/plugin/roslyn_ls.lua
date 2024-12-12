require("lz.n").load({
    "roslyn.nvim",
    ft = "cs",
    after = function()
        local binaries = require("pde.binaries")

        require("roslyn").setup({
            exe = binaries.roslyn_ls(),
            config = vim.lsp.config.roslyn,
        })
    end,
})
