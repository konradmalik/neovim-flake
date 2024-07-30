require("bigfile").setup({
    features = {
        "lsp",
        "treesitter",
        "syntax",
        -- "matchparen", will stay disabled even when I close the big file
        "vimopts",
        "filetype",
    },
})

