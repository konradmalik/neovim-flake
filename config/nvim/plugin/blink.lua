require("blink.cmp").setup({
    appearance = {
        kind_icons = require("pde.lsp.completion").kind_icons,
        nerd_font_variant = "normal",
    },

    completion = {
        documentation = {
            auto_show = true,
        },
    },

    fuzzy = {
        prebuilt_binaries = {
            download = false,
        },
    },
})
