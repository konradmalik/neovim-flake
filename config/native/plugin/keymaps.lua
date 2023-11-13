local opts_with_desc = function(desc, silent)
    if silent == nil then
        silent = true
    end
    local opts = { noremap = true, silent = silent }
    return vim.tbl_extend("error", opts, { desc = "[konrad] " .. desc })
end

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- to navigate buffers in normal mode
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<CR>", opts_with_desc("Prev buffer"))
vim.keymap.set("n", "<S-l>", "<cmd>bnext<CR>", opts_with_desc("Next buffer"))

-- quick grep word under the cursor
vim.keymap.set("n", "<leader>*", "<cmd>grep <cword><CR>", opts_with_desc("Grep word under cursor"))

-- quickfix niceness
vim.keymap.set("n", "<C-k>", "<cmd>cprevious<CR>", opts_with_desc("Go to previous QF element"))
vim.keymap.set("n", "<C-j>", "<cmd>cnext<CR>", opts_with_desc("Go to next QF element"))
vim.keymap.set("n", "<leader>k", "<cmd>lprevious<CR>", opts_with_desc("Go to previous LL element"))
vim.keymap.set("n", "<leader>j", "<cmd>lnext<CR>", opts_with_desc("Go to next LL element"))

vim.keymap.set("i", "<C-c>", "<esc>", opts_with_desc("Ctrl-c as ESC in insert mode"))

vim.keymap.set("v", "<leader>p", '"_dP', opts_with_desc("Replace selected by pasting and keep pasted in the register"))
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], opts_with_desc("delete without replacing your register"))

vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], opts_with_desc("yank to system clipboard"))
vim.keymap.set("n", "<leader>Y", [["+Y]], opts_with_desc("yank to system clipboard"))

vim.keymap.set("v", "J", ":m '>+1<CR>gv", opts_with_desc("move current selection up"))
vim.keymap.set("v", "K", ":m '<-2<CR>gv", opts_with_desc("move current selection down"))

vim.keymap.set(
    "n",
    "<leader>ss",
    [[viwy:%s/<C-r>0/]],
    opts_with_desc("prepopulate <cmd> to replace the current word", false)
)

vim.keymap.set("v", "<leader>ss", [[y:%s/<C-r>0/]], opts_with_desc("prepopulate <cmd> to replace the selection", false))
