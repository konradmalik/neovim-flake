local funs = require("pde.unimpaired.functions")

-- movement
vim.keymap.set("n", "<leader>q", funs.toggle_qflist, funs.opts_with_desc("Toggle Quickfix List"))
vim.keymap.set("n", "<leader>l", funs.toggle_llist, funs.opts_with_desc("Toggle Local List"))

vim.keymap.set(
    "n",
    "[f",
    funs.previous_file,
    funs.opts_with_desc("Previous file in directory. :colder in qflist")
)
vim.keymap.set(
    "n",
    "]f",
    funs.next_file,
    funs.opts_with_desc("Next file in directory. :cnewer in qflist")
)

-- registers
vim.keymap.set(
    "v",
    "<leader>p",
    '"_dP',
    funs.opts_with_desc("Replace selected by pasting and keep pasted in the register")
)
vim.keymap.set(
    { "n", "v" },
    "<leader>d",
    [["_d]],
    funs.opts_with_desc("delete without replacing your register")
)

vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], funs.opts_with_desc("yank to system clipboard"))
vim.keymap.set("n", "<leader>Y", [["+Y]], funs.opts_with_desc("yank to system clipboard"))

-- search and replace
vim.keymap.set(
    "n",
    "<leader>ss",
    [[viwy:%s/<C-r>0/]],
    funs.opts_with_desc("prepopulate <cmd> to replace the current word")
)

vim.keymap.set(
    "v",
    "<leader>ss",
    [[y:%s/<C-r>0/]],
    funs.opts_with_desc("prepopulate <cmd> to replace the selection")
)

-- misc
vim.keymap.set(
    "n",
    "<leader>*",
    "<cmd>grep <cword><CR>",
    funs.opts_with_desc("Grep word under cursor")
)

vim.keymap.set("i", "<C-c>", "<esc>", funs.opts_with_desc("Ctrl-c as ESC in insert mode"))

vim.keymap.set("v", "J", ":m '>+1<CR>gv", funs.opts_with_desc("move current selection up"))
vim.keymap.set("v", "K", ":m '<-2<CR>gv", funs.opts_with_desc("move current selection down"))
