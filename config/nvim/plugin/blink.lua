local mini_icons = require("mini.icons")

require("blink.cmp").setup({
    appearance = {
        nerd_font_variant = "normal",
    },

    completion = {
        documentation = {
            auto_show = true,
        },
        menu = {
            draw = {
                components = {
                    kind_icon = {
                        text = function(ctx)
                            local kind_icon, _, _ = mini_icons.get("lsp", ctx.kind)
                            return kind_icon .. ctx.icon_gap
                        end,
                    },
                },
            },
        },
    },

    fuzzy = {
        prebuilt_binaries = {
            download = false,
        },
    },

    sources = {
        cmdline = {},
    },
})
