-- https://github.com/sumneko/lua-language-server
local binaries = require("konrad.binaries")
local configs = require("konrad.lsp.configs")
local system = require("konrad.system")

return {
    config = function()
        local neovim_paths = { vim.env.VIMRUNTIME }
        local cwd = vim.uv.cwd()
        if cwd and not string.find(cwd, system.repository_name, nil, true) then
            table.insert(neovim_paths, vim.fn.stdpath("config"))
            ---@diagnostic disable-next-line: param-type-mismatch
            for _, dir in ipairs(vim.fn.stdpath("config_dirs")) do
                table.insert(neovim_paths, dir)
            end
        end

        ---@type vim.lsp.ClientConfig
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
                            unpack(neovim_paths),
                        },
                    },
                },
            },
            root_dir = configs.root_dir(".luarc.json", { type = "file" })
                or configs.root_dir({ "lua", ".git" }, { type = "directory" }),
        }
    end,
}
