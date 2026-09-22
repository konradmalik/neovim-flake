-- https://github.com/LuaLS/lua-language-server
---@type vim.lsp.Config
return {
    root_dir = function(bufnr, on_dir)
        -- .nvim.lua files get a dedicated client, see lsp/nvim_ls.lua
        if vim.fs.basename(vim.api.nvim_buf_get_name(bufnr)) ~= ".nvim.lua" then on_dir(nil) end
    end,
    on_init = function(client)
        -- use stylua via flint-ls, this formatter is not great and it clears diagnostic text on save
        client.server_capabilities.documentFormattingProvider = nil
        client.server_capabilities.documentRangeFormattingProvider = nil
    end,
    ---@type lspconfig.settings.lua_ls
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
