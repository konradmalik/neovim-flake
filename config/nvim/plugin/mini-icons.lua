local mini_icons = require("mini.icons")
mini_icons.setup({
    lsp = {
        constructor = { glyph = "" },
        ["function"] = { glyph = "󰊕" },
        method = { glyph = "󰊕" },

        field = { glyph = "󰜢" },
        property = { glyph = "󰖷" },
        variable = { glyph = "󰆦" },

        class = { glyph = "󰠱" },
        interface = { glyph = "" },
        module = { glyph = "" },
        namespace = { glyph = "" },
        object = { glyph = "" },
        package = { glyph = "" },
        struct = { glyph = "󱡠" },

        enum = { glyph = "" },
        enummember = { glyph = "" },
        unit = { glyph = "󰑭" },
        value = { glyph = "󰎠" },

        array = { glyph = "" },
        boolean = { glyph = "" },
        constant = { glyph = "󰏿" },
        keyword = { glyph = "󰻾" },
        null = { glyph = "󰟢" },
        number = { glyph = "" },
        string = { glyph = "" },
        text = { glyph = "" },

        color = { glyph = "󰏘" },
        event = { glyph = "" },
        file = { glyph = "󰈙" },
        folder = { glyph = "󰉋" },
        key = { glyph = "" },
        operator = { glyph = "󰆕" },
        reference = { glyph = "" },
        snippet = { glyph = "󱄽" },
        typeparameter = { glyph = "" },
    },
})
-- NOTE: I think this is only for telescope.nvim - hard nvim-web-devicons dependency
mini_icons.mock_nvim_web_devicons()
