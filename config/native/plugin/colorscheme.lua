require("kanagawa").setup({
    compile = true,
    background = {
        dark = "wave",
        light = "lotus"
    },
})

vim.o.background = "dark";
vim.cmd("colorscheme kanagawa")
