require("konrad.lazy").make_lazy_load("comment", { "BufNew", "BufRead" }, function()
    vim.cmd.packadd("comment.nvim")
    require("Comment").setup({
        mappings = {
            basic = true,
            extra = false,
        },
    })
end)
