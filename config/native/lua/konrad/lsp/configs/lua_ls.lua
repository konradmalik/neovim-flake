-- https://github.com/sumneko/lua-language-server
local binaries = require("konrad.binaries")
local configs = require("konrad.lsp.configs")

vim.cmd("packadd neodev.nvim")
require("neodev").setup({
    lspconfig = false,
})

---@type LspConfig
return {
    config = function()
        local config = {
            name = "lua_ls",
            cmd = { binaries.lua_ls() },
            init_options = {
                documentFormatting = false,
                documentRangeFormatting = false,
            },
            on_init = function(client)
                -- use stylua via efm, this formatter is not great and it clears diagnostic text on save
                client.server_capabilities.documentFormattingProvider = nil
                client.server_capabilities.documentRangeFormattingProvider = nil
            end,
            settings = {
                Lua = {
                    addonManager = { enable = false },
                    telemetry = { enable = false },
                    hint = { enable = true },
                    -- use stylua via efm, this formatter is not great and it clears diagnostic text on save
                    format = { enable = false },
                    workspace = { checkThirdParty = false },
                },
            },
            root_dir = configs.root_dir(".luarc.json", { type = "file" })
                or configs.root_dir({ "lua", ".git" }, { type = "directory" }),
        }

        -- this mutates config, so we cannot return a new one each time
        require("neodev.lsp").on_new_config(config, config.root_dir)
        return config
    end,
}
