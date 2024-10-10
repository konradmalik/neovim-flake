-- https://github.com/LuaLS/lua-language-server
local binaries = require("pde.binaries")

return {
    ---@param bufnr integer
    ---@return vim.lsp.ClientConfig
    config = function(bufnr)
        ---@type vim.lsp.ClientConfig
        return {
            name = "lua_ls",
            cmd = { binaries.lua_ls() },
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
            root_dir = vim.fs.root(bufnr, ".luarc.json") or vim.fs.root(0, { "lua", ".git" }),
        }
    end,
}
