local harpoon = require("harpoon")
harpoon:setup()

local opts = { noremap = true, silent = true }
local opts_with_desc = function(desc)
    return vim.tbl_extend("error", opts, { desc = "[Harpoon] " .. desc })
end

vim.keymap.set("n", "<leader>ha", function()
    harpoon:list():append()
end, opts_with_desc("Add file"))
vim.keymap.set("n", "<leader>ht", function()
    harpoon.ui:toggle_quick_menu(harpoon:list())
end, opts_with_desc("Toggle Menu"))
vim.keymap.set("n", "<leader>hj", function()
    harpoon:list():select(1)
end, opts_with_desc("Go to 1"))
vim.keymap.set("n", "<leader>hk", function()
    harpoon:list():select(2)
end, opts_with_desc("Go to 2"))
vim.keymap.set("n", "<leader>hl", function()
    harpoon:list():select(3)
end, opts_with_desc("Go to 3"))
vim.keymap.set("n", "<leader>h;", function()
    harpoon:list():select(4)
end, opts_with_desc("Go to 4"))

