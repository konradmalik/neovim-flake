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
    overrides = function(colors)
        local theme = colors.theme
        return {
            Pmenu = { link = "NormalFloat" },
            PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2 },
            PmenuKind = { link = "Pmenu" },
            PmenuKindSel = { link = "PmenuSel" },
            PmenuBorder = { link = "FloatBorder" },
            PmenuExtra = { link = "Pmenu" },
            PmenuExtraSel = { link = "PmenuSel" },
            PmenuSbar = { bg = theme.ui.bg_m1 },
            PmenuThumb = { bg = theme.ui.bg_p2 },
        }
    end,
})

vim.o.background = "dark"
vim.cmd.colorscheme("kanagawa")
require("pde.loader").add_to_on_reset(function() vim.cmd("KanagawaCompile") end)
