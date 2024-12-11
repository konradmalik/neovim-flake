-- https://github.com/LuaLS/lua-language-server
local binaries = require("pde.binaries")

vim.lsp.config("lua_ls", {
    cmd = { binaries.lua_ls() },
    filetypes = { "lua" },
    on_init = function(client)
        -- use stylua via efm, this formatter is not great and it clears diagnostic text on save
        client.server_capabilities.documentFormattingProvider = nil
        client.server_capabilities.documentRangeFormattingProvider = nil
    end,
    settings = {
        Lua = {
            addonManager = { enable = false },
            -- use stylua via efm, this formatter is not great and it clears diagnostic text on save
            format = { enable = false },
            hint = { enable = true },
            runtime = { version = "LuaJIT" },
            telemetry = { enable = false },
            workspace = {
                checkThirdParty = false,
            },
        },
    },
    root_markers = { ".luarc.json" },
})
