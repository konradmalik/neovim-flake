local utils = require("konrad.utils")
utils.make_enable_command(
    "Git",
    { "vim-fugitive" },
    function()
        vim.cmd("Git")
    end,
    {
        desc = "Initialize fugitive and open it",
    })
