-- https://github.com/LuaLS/lua-language-server
---@type vim.lsp.Config
return {
    on_init = function(client)
        -- use stylua via flint-ls, this formatter is not great and it clears diagnostic text on save
        client.server_capabilities.documentFormattingProvider = nil
        client.server_capabilities.documentRangeFormattingProvider = nil
    end,
    settings = {
        Lua = {
            addonManager = { enable = false },
            -- use stylua via flint-ls, this formatter is not great and it clears diagnostic text on save
            format = { enable = false },
            hint = { enable = true },
            runtime = { version = "LuaJIT" },
            telemetry = { enable = false },
            workspace = {
                checkThirdParty = false,
            },
        },
    },
}
