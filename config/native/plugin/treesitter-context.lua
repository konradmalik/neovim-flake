require("lz.n").load({
    "nvim-treesitter-context",
    event = { "BufNew", "BufRead" },
    after = function() require("treesitter-context").setup() end,
})
