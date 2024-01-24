require("konrad.lazy").make_enable_command(
    "UndotreeToggle",
    { "undotree" },
    function() vim.cmd("UndotreeToggle") end,
    {
        desc = "Initialize Undotree and open it",
    }
)
