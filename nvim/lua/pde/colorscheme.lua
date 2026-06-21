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
            StatusLine = { fg = theme.ui.fg_dim, bg = theme.ui.bg },
            StatusLineNC = { fg = theme.ui.nontext, bg = theme.ui.bg },

            Pmenu = { link = "BlinkCmpMenu" },
            PmenuSel = { link = "BlinkCmpMenuSelection" },
            PmenuKind = { link = "BlinkCmpKind" },
            PmenuKindSel = { link = "BlinkCmpMenuSelection" },
            PmenuBorder = { link = "BlinkCmpMenuBorder" },
            PmenuExtra = { link = "BlinkCmpLabel" },
            PmenuExtraSel = { link = "BlinkCmpMenuSelection" },
            PmenuSbar = { link = "BlinkCmpScrollBarGutter" },
            PmenuThumb = { link = "BlinkCmpScrollBarThumb" },
            ["@lsp.mod.deprecated"] = { link = "BlinkCmpLabelDeprecated" },
        }
    end,
})

vim.o.background = "dark"
vim.cmd.colorscheme("kanagawa")
require("pde.loader").add_to_on_reset(function() vim.cmd("KanagawaCompile") end)
