-- https://github.com/sumneko/lua-language-server
local binaries = require("konrad.binaries")
local configs = require("konrad.lsp.configs")

local M = {}

function M.config()
    vim.cmd("packadd neodev.nvim")
    require("neodev").setup({
        lspconfig = false,
    })

    local before_init = require("neodev.lsp").before_init

    return {
        name = "lua_ls",
        cmd = { binaries.lua_ls() },
        before_init = before_init,
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
end

return M
