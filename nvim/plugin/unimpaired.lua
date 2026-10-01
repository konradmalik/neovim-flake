---@param desc string
---@param extra? vim.keymap.set.Opts
local function opts_with_desc(desc, extra)
    return vim.tbl_extend("force", { desc = "[unimpaired] " .. desc }, extra or {})
end

---@param name string function in pde.unimpaired, required on first use
local function un(name)
    return function() require("pde.unimpaired")[name]() end
end

-- NOTE: visual mappings use "x", not "v": "v" also covers Select mode (snippet placeholders),
-- where typing J, K or <leader> would then trigger the mapping instead of inserting text

-- movement
vim.keymap.set("n", "<leader>q", un("toggle_qflist"), opts_with_desc("Toggle Quickfix List"))
vim.keymap.set("n", "<leader>l", un("toggle_llist"), opts_with_desc("Toggle Location List"))

vim.keymap.set("n", "[f", un("previous_file"), opts_with_desc("Previous file in directory"))
vim.keymap.set("n", "]f", un("next_file"), opts_with_desc("Next file in directory"))

-- registers
vim.keymap.set("x", "<leader>d", [["_d]], opts_with_desc("delete without replacing your register"))

vim.keymap.set({ "n", "x" }, "<leader>y", [["+y]], opts_with_desc("yank to system clipboard"))
vim.keymap.set("n", "<leader>Y", [["+Y]], opts_with_desc("yank to system clipboard"))

-- search and replace: the text goes in as a literal (\V) pattern, no register is touched
---@param lines string[]
---@return string keys for an expr mapping with replace_keycodes = false
local function substitute(lines)
    local escaped = vim.tbl_map(function(line) return vim.fn.escape(line, "/\\") end, lines)
    return ":%s/\\V" .. table.concat(escaped, "\\n") .. "/"
end
local raw_expr = { expr = true, replace_keycodes = false }

vim.keymap.set(
    "n",
    "<leader>ss",
    function() return substitute({ vim.fn.expand("<cword>") }) end,
    opts_with_desc("prepopulate <cmd> to replace the current word", raw_expr)
)
vim.keymap.set("x", "<leader>ss", function()
    local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = vim.fn.mode() })
    return "\27" .. substitute(lines) -- <Esc> first: leave Visual mode
end, opts_with_desc("prepopulate <cmd> to replace the selection", raw_expr))

-- misc
vim.keymap.set("n", "<leader>*", "<cmd>silent grep! <cword><CR>", opts_with_desc("Grep word under cursor"))

vim.keymap.set("i", "<C-c>", "<esc>", opts_with_desc("Ctrl-c as ESC in insert mode"))

vim.keymap.set("x", "J", ":<C-u>silent! '<,'>m '>+1<CR>gv", opts_with_desc("move current selection down"))
vim.keymap.set("x", "K", ":<C-u>silent! '<,'>m '<-2<CR>gv", opts_with_desc("move current selection up"))
