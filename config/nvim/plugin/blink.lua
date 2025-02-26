local mini_icons = require("mini.icons")

require("blink.cmp").setup({
    completion = {
        documentation = {
            auto_show = true,
        },
        menu = {
            draw = {
                treesitter = { "lsp" },
                components = {
                    kind_icon = {
                        text = function(ctx)
                            local kind_icon, _, _ = mini_icons.get("lsp", ctx.kind)
                            return kind_icon .. ctx.icon_gap
                        end,
                        highlight = function(ctx)
                            local _, hl, _ = mini_icons.get("lsp", ctx.kind)
                            return hl
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

    cmdline = {
        enabled = false,
    },
})
