require("rose-pine").setup({
    dim_inactive_windows = true,
    extend_background_behind_borders = true,

    enable = {
        terminal = true,
    },

    styles = {
        bold = true,
        italic = true,
        transparency = false,
    },
})

vim.o.background = "dark"
vim.cmd.colorscheme("rose-pine")
