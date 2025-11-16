require("kanagawa").setup({
    compile = true,
    background = {
        dark = "wave",
        light = "lotus",
    },
    colors = {
        theme = {
            all = {
                ui = {
                    bg_gutter = "none",
                },
            },
        },
    },
    overrides = function(_)
        return {
            Pmenu = { link = "BlinkCmpMenu" },
            PmenuSel = { link = "BlinkCmpMenuSelection" },
            PmenuKind = { link = "BlinkCmpKind" },
            PmenuKindSel = { link = "BlinkCmpMenuSelection" },
            PmenuBorder = { link = "BlinkCmpMenuBorder" },
            PmenuExtra = { link = "BlinkCmpLabel" },
            PmenuExtraSel = { link = "BlinkCmpMenuSelection" },
            PmenuSbar = { link = "BlinkCmpScrollBarGutter" },
            PmenuThumb = { link = "BlinkCmpScrollBarThumb" },
        }
    end,
})

vim.o.background = "dark"
vim.cmd.colorscheme("kanagawa")
require("pde.loader").add_to_on_reset(function() vim.cmd("KanagawaCompile") end)
