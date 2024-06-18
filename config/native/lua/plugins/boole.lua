return {
    "boole.nvim",
    event = { "BufNew", "BufRead" },
    after = function()
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
    end,
}
