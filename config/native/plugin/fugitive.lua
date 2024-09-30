local opts_with_desc = function(desc) return { desc = "[fUgitive] " .. desc } end

vim.keymap.set("v", "<leader>ul", ":Gclog!<CR>", opts_with_desc("history of the selected lines"))
vim.keymap.set("n", "<leader>ul", ":0Gclog!<CR>", opts_with_desc("history of the current file"))
vim.keymap.set(
    "n",
    "<leader>uL",
    ":Gclog! %<CR>",
    opts_with_desc("commits history of the current file")
)
