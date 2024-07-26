vim.keymap.set(
    { "i", "s" },
    "<c-k>",
    function() return vim.snippet.active({ direction = 1 }) and vim.snippet.jump(1) end,
    { silent = true }
)

vim.keymap.set(
    { "i", "s" },
    "<c-j>",
    function() return vim.snippet.active({ direction = -1 }) and vim.snippet.jump(-1) end,
    { silent = true }
)
