local utils = require("konrad.utils")
utils.make_enable_command(
    "Neogit",
    { "neogit" },
    function()
        local neogit = require('neogit')
        neogit.setup {}
        neogit.open()
    end,
    {
        desc = "Initialize Neogit and open it",
    },
    true)
