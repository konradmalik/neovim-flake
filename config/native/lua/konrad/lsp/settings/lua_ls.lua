-- https://github.com/sumneko/lua-language-server
vim.cmd('packadd neodev.nvim')
local neodev = require("neodev")
neodev.setup({
    -- add any options here, or leave empty to use the default settings
})

return {
    settings = {
        Lua = {
            telemetry = { enable = false },
            hint = { enable = true },
            format = { enable = true },
        }
    }
}
