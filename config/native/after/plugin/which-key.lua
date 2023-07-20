local utils = require("konrad.utils")
utils.lazy_load("which-key.nvim", function()
    local which_key = require("which-key")

    which_key.setup({
        disable = {
            buftypes = {},
            filetypes = { "TelescopePrompt" },
        }
    })
end)
