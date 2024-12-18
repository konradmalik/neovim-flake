-- [[ Setting options ]]
-- See `:help vim.o`
-- use spaces instead of tabs. Mostly useful for new files not in repos/isolated files etc.
-- Most of the time editorconfig should be used (neovim loads it automatically)
vim.o.shiftwidth = 4
vim.o.softtabstop = -1 -- negative means just use shiftwidth
vim.o.expandtab = true
-- indenting
vim.o.smartindent = true
vim.o.autoindent = true
-- Set highlight on search. Use :noh to disable until next search
vim.o.hlsearch = true
-- incrementally search
vim.o.incsearch = true
-- Enable mouse mode
vim.o.mouse = "a"
-- Enable break indent
vim.o.breakindent = true
-- don't create a swapfile
vim.o.swapfile = false
-- don't create a backup file
vim.o.backup = false
-- Save undo history
vim.o.undofile = true
vim.o.undodir = vim.fn.stdpath("state") .. "/undodir"
-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true
-- Keep signcolumn on by default
-- but restrict to just 1 place
vim.o.signcolumn = "yes"
-- show some hidden chars
vim.o.list = true
vim.opt.listchars = {
    trail = "·",
    tab = "-->",
    nbsp = "󱁐",
    extends = "",
    precedes = "",
    leadmultispace = "┊ ",
}
-- Lines of context when scrolling
vim.o.scrolloff = 10
-- Columns of context when scrolling
vim.o.sidescrolloff = 10
-- Decrease update time
vim.o.updatetime = 1000
vim.o.timeoutlen = 1000
-- highlight the current line
vim.o.cursorline = true
