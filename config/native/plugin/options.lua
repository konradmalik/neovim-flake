local icons = require("konrad.icons")

-- [[ Setting options ]]
-- See `:help vim.o`
-- use spaces instead of tabs. Mostly useful for new files not in repos/isolated files etc.
-- Most of the time editorconfig should be used (neovim loads it automatically)
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
-- Set highlight on search. Use :noh to disable until next search
vim.opt.hlsearch = true
-- Make line numbers default
vim.opt.number = true
-- Relative line numbers
vim.opt.relativenumber = true
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
-- when a file was modified outside of vim and not modified in vim, we can read it automatically
vim.bo.autoread = true
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
    trail = icons.characters.Trail,
    tab = icons.characters.Tab .. "-" .. icons.characters.Tab,
    nbsp = icons.characters.Nbsp2,
    extends = icons.characters.SlopeDown,
    precedes = icons.characters.SlopeUp,
    leadmultispace = icons.ui.Guide .. " ",
}
-- Lines of context when scrolling
vim.opt.scrolloff = 10
-- Columns of context when scrolling
vim.opt.sidescrolloff = 10
-- Decrease update time
vim.opt.updatetime = 1000
vim.opt.timeoutlen = 1000
-- True color support
vim.opt.termguicolors = true
-- highlight the current line
vim.opt.cursorline = true
-- use ripgrep as grep program
vim.opt.grepprg = "rg --vimgrep --no-heading --smart-case"
vim.opt.grepformat = { "%f:%l:%c:%m", "%f:%l:%m" }
