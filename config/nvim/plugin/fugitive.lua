local opts_with_desc = function(desc) return { desc = "[fuGitive] " .. desc } end

vim.keymap.set(
    "v",
    "<leader>gh",
    ":Gllog!<CR>",
    opts_with_desc("history of the selected lines in loclist")
)
vim.keymap.set(
    "n",
    "<leader>gh",
    ":0Gllog!<CR>",
    opts_with_desc("history of the current file in loclist")
)
vim.keymap.set(
    "n",
    "<leader>gvl",
    ":vertical Git log -p -- %<CR>",
    opts_with_desc("current file's commits in a split")
)
