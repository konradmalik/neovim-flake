require("konrad.lazy").make_lazy_load("boole", { "BufNew", "BufRead" }, function()
    require("boole").setup({
        mappings = {
            increment = "<C-a>",
            decrement = "<C-x>",
        },
        -- User defined loops
        additions = {
            -- {'Foo', 'Bar'},
            -- {'tic', 'tac', 'toe'}
        },
    })
end)
