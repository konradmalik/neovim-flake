local utils = require("konrad.utils")
utils.lazy_load("j-hui", function()
        local fidget = require("fidget")
        fidget.setup {
            text = {
                spinner = "dots",
            },
            window = {
                relative = "editor",
            },
        }
    end,
    { "BufReadPre", "BufNewFile" }
)
