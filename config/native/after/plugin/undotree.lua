local utils = require("konrad.utils")
utils.make_enable_command(
    "UndotreeToggle",
    { "undotree" },
    function()
        vim.cmd("UndotreeToggle")
    end,
    {
        desc = "Initialize Undotree and open it",
    },
    -- no idea why if we delete UndotreeToggle before running packadd
    -- then the command from UndotreeToggle from undotree itself is also deleted...
    false)

utils.make_enable_command(
    "UndotreeToggle",
    { "undotree" },
    function()
        vim.cmd("UndotreeToggle")
    end,
    {
        desc = "Initialize Undotree and open it",
    },
    -- no idea why if we delete UndotreeToggle before running packadd
    -- then the command from UndotreeToggle from undotree itself is also deleted...
    false)
