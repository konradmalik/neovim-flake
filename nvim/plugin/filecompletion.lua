local filecompletion = require("pde.filecompletion")

local keys = vim.keycode("<C-x><C-f>")

vim.keymap.set("i", "<C-x><C-f>", function()
    filecompletion.use_buffer_dir(vim.api.nvim_get_current_buf())
    vim.api.nvim_feedkeys(keys, "n", false)
end, { desc = "File name completion relative to the current file" })
