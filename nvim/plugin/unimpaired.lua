local function opts_with_desc(desc) return { desc = "[unimpaired] " .. desc } end

local un = require("pde.unimpaired")

-- movement
vim.keymap.set("n", "<leader>q", un.toggle_qflist, opts_with_desc("Toggle Quickfix List"))
vim.keymap.set("n", "<leader>l", un.toggle_llist, opts_with_desc("Toggle Local List"))

vim.keymap.set("n", "[f", un.previous_file, opts_with_desc("Previous file in directory"))
vim.keymap.set("n", "]f", un.next_file, opts_with_desc("Next file in directory"))

-- registers
vim.keymap.set("v", "<leader>d", [["_d]], opts_with_desc("delete without replacing your register"))

vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], opts_with_desc("yank to system clipboard"))
vim.keymap.set("n", "<leader>Y", [["+Y]], opts_with_desc("yank to system clipboard"))

-- search and replace
vim.keymap.set(
    "n",
    "<leader>ss",
    [[viwy:%s/<C-r>0/]],
    opts_with_desc("prepopulate <cmd> to replace the current word")
)

vim.keymap.set(
    "v",
    "<leader>ss",
    [[y:%s/<C-r>0/]],
    opts_with_desc("prepopulate <cmd> to replace the selection")
)

-- misc
vim.keymap.set("n", "<leader>*", "<cmd>grep <cword><CR>", opts_with_desc("Grep word under cursor"))

vim.keymap.set("i", "<C-c>", "<esc>", opts_with_desc("Ctrl-c as ESC in insert mode"))

vim.keymap.set("v", "J", ":m '>+1<CR>gv", opts_with_desc("move current selection up"))
vim.keymap.set("v", "K", ":m '<-2<CR>gv", opts_with_desc("move current selection down"))
