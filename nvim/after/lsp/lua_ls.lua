-- https://github.com/LuaLS/lua-language-server
---@type vim.lsp.Config
return {
    root_dir = function(bufnr, on_dir)
        -- .nvim.lua files get a dedicated client, see lsp/nvim_ls.lua
        if vim.fs.basename(vim.api.nvim_buf_get_name(bufnr)) ~= ".nvim.lua" then on_dir(nil) end
    end,
    ---@type lspconfig.settings.lua_ls
    settings = {
        Lua = {
            addonManager = { enable = false },
            hint = { enable = true },
            runtime = { version = "LuaJIT" },
            telemetry = { enable = false },
            workspace = {
                checkThirdParty = false,
            },
        },
    },
}
