local funs = require("konrad.unimpaired.functions")

local opts_with_desc = function(desc)
    local opts = { noremap = true, silent = true }
    return vim.tbl_extend("error", opts, { desc = "[unimpaired] " .. desc })
end

vim.keymap.set("n", "[a", funs.previous, opts_with_desc("jump to previous file in arglist"))
vim.keymap.set("n", "]a", funs.next, opts_with_desc("jump to next file in arglist"))
vim.keymap.set("n", "[A", funs.first, opts_with_desc("jump to first file in arglist"))
vim.keymap.set("n", "]A", funs.last, opts_with_desc("jump to last file in arglist"))

vim.keymap.set("n", "[b", funs.bprevious, opts_with_desc("jump to previous buffer"))
vim.keymap.set("n", "]b", funs.bnext, opts_with_desc("jump to next buffer"))
vim.keymap.set("n", "[B", funs.bfirst, opts_with_desc("jump to first buffer"))
vim.keymap.set("n", "]B", funs.blast, opts_with_desc("jump to last buffer"))

vim.keymap.set("n", "[l", funs.lprevious, opts_with_desc("jump to previous entry in loclist"))
vim.keymap.set("n", "]l", funs.lnext, opts_with_desc("jump to next entry in loclist"))
vim.keymap.set("n", "[L", funs.lfirst, opts_with_desc("jump to first entry in loclist"))
vim.keymap.set("n", "]L", funs.llast, opts_with_desc("jump to last entry in loclist"))
vim.keymap.set("n", "[<C-l>", funs.lpfile, opts_with_desc("jump to last entry of previous file in loclist"))
vim.keymap.set("n", "]<C-l>", funs.lnfile, opts_with_desc("jump to first entry of next file in loclist"))

vim.keymap.set("n", "[q", funs.cprevious, opts_with_desc("jump to previous entry in qflist"))
vim.keymap.set("n", "]q", funs.cnext, opts_with_desc("jump to next entry in qflist"))
vim.keymap.set("n", "[Q", funs.cfirst, opts_with_desc("jump to first entry in qflist"))
vim.keymap.set("n", "]Q", funs.clast, opts_with_desc("jump to last entry in qflist"))
vim.keymap.set("n", "[<C-q>", funs.cpfile, opts_with_desc("jump to last entry of previous file in qflist"))
vim.keymap.set("n", "]<C-q>", funs.cnfile, opts_with_desc("jump to first entry of next file in qflist"))

vim.keymap.set("n", "[t", funs.tprevious, opts_with_desc("jump to previous matching tag"))
vim.keymap.set("n", "]t", funs.tnext, opts_with_desc("jump to next matching tag"))
vim.keymap.set("n", "[T", funs.tfirst, opts_with_desc("jump to first matching tag"))
vim.keymap.set("n", "]T", funs.tlast, opts_with_desc("jump to last matching tag"))
vim.keymap.set("n", "[<C-t>", funs.ptprevious, opts_with_desc(":tprevious in the preview window"))
vim.keymap.set("n", "]<C-t>", funs.ptnext, opts_with_desc(":tnext in the preview window"))

vim.keymap.set("n", "[f", funs.previous_file, opts_with_desc("Previous file in directory. :colder in qflist"))
vim.keymap.set("n", "]f", funs.next_file, opts_with_desc("Next file in directory. :cnewer in qflist"))
