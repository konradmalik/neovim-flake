local boole = require("boole")

boole.setup({
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
