require("lz.n").load({
    "roslyn.nvim",
    ft = "cs",
    after = function()
        local lspconfig = require("pde.lsp.configs.roslyn_ls")
        require("roslyn").setup(lspconfig.get_roslyn_config())
    end,
})
