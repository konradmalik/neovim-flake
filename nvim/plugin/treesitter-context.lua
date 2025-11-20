local tscontext = require("treesitter-context")
tscontext.setup({
    min_window_height = 40,
    multiline_threshold = 10,
})

vim.keymap.set(
    "n",
    "[c",
    function() tscontext.go_to_context(vim.v.count1) end,
    { silent = true, desc = "Jump to co[n]text" }
)
