local harpoon = require("harpoon")

harpoon:setup()

---@param desc string
---@return table
local function opts_with_desc(desc) return { desc = "[hArpoon] " .. desc } end

vim.keymap.set(
    "n",
    "<leader>aa",
    function() harpoon:list():add() end,
    opts_with_desc("add to list")
)
vim.keymap.set(
    "n",
    "<leader>aq",
    function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
    opts_with_desc("toggle quick menu")
)

vim.keymap.set(
    "n",
    "<leader>aj",
    function() harpoon:list():select(1) end,
    opts_with_desc("first entry")
)
vim.keymap.set(
    "n",
    "<leader>ak",
    function() harpoon:list():select(2) end,
    opts_with_desc("second entry")
)
vim.keymap.set(
    "n",
    "<leader>al",
    function() harpoon:list():select(3) end,
    opts_with_desc("third entry")
)
vim.keymap.set(
    "n",
    "<leader>a;",
    function() harpoon:list():select(4) end,
    opts_with_desc("fourth entry")
)

