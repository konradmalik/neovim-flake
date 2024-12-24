require("blink.cmp").setup({
    appearance = {
        kind_icons = require("pde.lsp.completion").kind_icons,
        nerd_font_variant = "normal",
    },

    completion = {
        documentation = {
            auto_show = true,
        },
        -- don't show automatically in cmdline
        menu = { auto_show = function(ctx) return ctx.mode ~= "cmdline" end },
    },

    fuzzy = {
        prebuilt_binaries = {
            download = false,
        },
    },
})
