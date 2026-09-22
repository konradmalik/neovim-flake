-- lua_ls for .nvim.lua files, which are neovim lua no matter what project they live in.
-- lua_ls pulls one workspace-wide config (no scopeUri), so the only way to keep neovim's
-- types out of the project's own lua is a separate client, in single file mode.
-- this repo doesn't need it, it has a generated .luarc.json.
local config = vim.tbl_deep_extend("force", vim.lsp.config.lua_ls, {
    root_dir = function(bufnr, on_dir)
        if vim.fs.basename(vim.api.nvim_buf_get_name(bufnr)) == ".nvim.lua" then on_dir(nil) end
    end,
    settings = {
        Lua = { workspace = { library = vim.api.nvim_get_runtime_file("lua", true) } },
    },
})

-- single file mode, force after merging
config.root_markers = nil

---@type vim.lsp.Config
return config
