local funs = require("pde.unimpaired.functions")

-- movement
vim.keymap.set("n", "[a", funs.previous, funs.opts_with_desc("jump to previous file in arglist"))
vim.keymap.set("n", "]a", funs.next, funs.opts_with_desc("jump to next file in arglist"))
vim.keymap.set("n", "[A", funs.first, funs.opts_with_desc("jump to first file in arglist"))
vim.keymap.set("n", "]A", funs.last, funs.opts_with_desc("jump to last file in arglist"))

vim.keymap.set("n", "[b", funs.bprevious, funs.opts_with_desc("jump to previous buffer"))
vim.keymap.set("n", "]b", funs.bnext, funs.opts_with_desc("jump to next buffer"))
vim.keymap.set("n", "[B", funs.bfirst, funs.opts_with_desc("jump to first buffer"))
vim.keymap.set("n", "]B", funs.blast, funs.opts_with_desc("jump to last buffer"))

vim.keymap.set("n", "[l", funs.lprevious, funs.opts_with_desc("jump to previous entry in loclist"))
vim.keymap.set("n", "]l", funs.lnext, funs.opts_with_desc("jump to next entry in loclist"))
vim.keymap.set("n", "[L", funs.lfirst, funs.opts_with_desc("jump to first entry in loclist"))
vim.keymap.set("n", "]L", funs.llast, funs.opts_with_desc("jump to last entry in loclist"))
vim.keymap.set(
    "n",
    "[<C-l>",
    funs.lpfile,
    funs.opts_with_desc("jump to last entry of previous file in loclist")
)
vim.keymap.set(
    "n",
    "]<C-l>",
    funs.lnfile,
    funs.opts_with_desc("jump to first entry of next file in loclist")
)

vim.keymap.set("n", "[q", funs.cprevious, funs.opts_with_desc("jump to previous entry in qflist"))
vim.keymap.set("n", "]q", funs.cnext, funs.opts_with_desc("jump to next entry in qflist"))
vim.keymap.set("n", "[Q", funs.cfirst, funs.opts_with_desc("jump to first entry in qflist"))
vim.keymap.set("n", "]Q", funs.clast, funs.opts_with_desc("jump to last entry in qflist"))
vim.keymap.set(
    "n",
    "[<C-q>",
    funs.cpfile,
    funs.opts_with_desc("jump to last entry of previous file in qflist")
)
vim.keymap.set(
    "n",
    "]<C-q>",
    funs.cnfile,
    funs.opts_with_desc("jump to first entry of next file in qflist")
)

vim.keymap.set("n", "<leader>q", funs.toggle_qflist, funs.opts_with_desc("Toggle Quickfix List"))
vim.keymap.set("n", "<leader>l", funs.toggle_llist, funs.opts_with_desc("Toggle Local List"))

vim.keymap.set("n", "[t", funs.tprevious, funs.opts_with_desc("jump to previous matching tag"))
vim.keymap.set("n", "]t", funs.tnext, funs.opts_with_desc("jump to next matching tag"))
vim.keymap.set("n", "[T", funs.tfirst, funs.opts_with_desc("jump to first matching tag"))
vim.keymap.set("n", "]T", funs.tlast, funs.opts_with_desc("jump to last matching tag"))
vim.keymap.set(
    "n",
    "[<C-t>",
    funs.ptprevious,
    funs.opts_with_desc(":tprevious in the preview window")
)
vim.keymap.set("n", "]<C-t>", funs.ptnext, funs.opts_with_desc(":tnext in the preview window"))

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
