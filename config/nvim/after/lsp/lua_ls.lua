-- https://github.com/LuaLS/lua-language-server
---@type vim.lsp.Config
return {
    cmd = { "lua-language-server" },
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
}
