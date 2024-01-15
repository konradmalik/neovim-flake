local opts_with_desc = function(desc) return { desc = "[Fugitive] " .. desc } end

vim.keymap.set("v", "<leader>gl", ":Gclog!<CR>", opts_with_desc("history of the selected lines"))
vim.keymap.set("n", "<leader>gl", ":0Gclog!<CR>", opts_with_desc("history of the current file"))
vim.keymap.set("n", "<leader>gL", ":Gclog! %<CR>", opts_with_desc("commits history of the current file"))
