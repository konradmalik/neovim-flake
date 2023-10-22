-- https://github.com/sumneko/lua-language-server
vim.cmd("packadd neodev.nvim")
local neodev = require("neodev")
neodev.setup({
    -- add any options here, or leave empty to use the default settings
})

local binaries = require("konrad.binaries")
return {
    cmd = { binaries.lua_ls() },
    init_options = {
        documentFormatting = false,
        documentRangeFormatting = false,
    },
    on_init = function(client)
        -- use stylua via efm, this formatter is not great and it cleares diagnostic text on save
        client.server_capabilities.documentFormattingProvider = nil
        client.server_capabilities.documentRangeFormattingProvider = nil
    end,
    settings = {
        Lua = {
            addonManager = { enable = false },
            telemetry = { enable = false },
            hint = { enable = true },
            -- use stylua via efm, this formatter is not great and it cleares diagnostic text on save
            format = { enable = false },
        },
    },
}
