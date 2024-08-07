-- [[ Setting options ]]
-- See `:help vim.o`
-- use spaces instead of tabs. Mostly useful for new files not in repos/isolated files etc.
-- Most of the time editorconfig should be used (neovim loads it automatically)
vim.opt.shiftwidth = 4
vim.opt.softtabstop = -1 -- negative means just use shiftwidth
vim.opt.expandtab = true
-- indenting
vim.opt.smartindent = true
vim.opt.autoindent = true
-- Set highlight on search. Use :noh to disable until next search
vim.opt.hlsearch = true
-- incrementally search
vim.opt.incsearch = true
-- Enable mouse mode
vim.opt.mouse = "a"
-- Enable break indent
vim.opt.breakindent = true
-- don't create a swapfile
vim.opt.swapfile = false
-- don't create a backup file
vim.opt.backup = false
-- Save undo history
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("state") .. "/undodir"
-- Case insensitive searching UNLESS /C or capital in search
vim.opt.ignorecase = true
vim.opt.smartcase = true
-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"
-- show some hidden chars
vim.opt.list = true
vim.opt.listchars = {
    trail = "·",
    tab = "--▷",
    nbsp = "○",
    extends = "◣",
    precedes = "◢",
    leadmultispace = "┊ ",
}
-- Lines of context when scrolling
vim.opt.scrolloff = 10
-- Columns of context when scrolling
vim.opt.sidescrolloff = 10
-- Decrease update time
vim.opt.updatetime = 1000
vim.opt.timeoutlen = 1000
-- highlight the current line
vim.opt.cursorline = true
