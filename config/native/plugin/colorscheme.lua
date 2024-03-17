require("kanagawa").setup({
    compile = true,
    background = {
        dark = "wave",
        light = "lotus",
    },
})

vim.opt.background = "dark"
vim.cmd.colorscheme("kanagawa")
require("konrad.loader").add_to_on_reset(function() vim.cmd("KanagawaCompile") end)
