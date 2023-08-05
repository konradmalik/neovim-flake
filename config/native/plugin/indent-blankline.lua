local indent_blankline = require("indent_blankline")
local icons = require("konrad.icons").ui

indent_blankline.setup {
    char = icons.Guide,
    use_treesitter = true,
    show_current_context = true,
}
