-- https://github.com/sumneko/lua-language-server
local binaries = require("konrad.binaries")
local configs = require("konrad.lsp.configs")

---@type LspConfig
return {
    name = "lua_ls",
    config = function()
        return {
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
                    -- use stylua via efm, this formatter is not great and it clears diagnostic text on save
                    format = { enable = false },
                    hint = { enable = true },
                    runtime = { version = "LuaJIT" },
                    telemetry = { enable = false },
                    workspace = {
                        checkThirdParty = false,
                        -- nvim
                        library = {
                            "${3rd}/luv/library",
                            -- unpack(vim.api.nvim_get_runtime_file("", true)),
                            -- this does not include plugins but is much smaller and faster
                            vim.env.VIMRUNTIME,
                        },
                    },
                },
            },
            root_dir = configs.root_dir(".luarc.json", { type = "file" })
                or configs.root_dir({ "lua", ".git" }, { type = "directory" }),
        }
    end,
}
