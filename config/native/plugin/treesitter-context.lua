require("konrad.lazy").make_lazy_load("treesitter-context", { "BufNew", "BufRead" }, function()
    vim.cmd.packadd("nvim-treesitter-context")

    require("treesitter-context").setup()
end)
