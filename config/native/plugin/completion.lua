vim.opt.completeopt = { "menu", "menuone", "noselect" }

---@param fpattern string filename pattern
---@return integer
--HACK:this is needed only for cmp sources because they (incorrectly) use "after/plugin"
--folder to register themselves.
local function load_after_plugin(fpattern)
    --- based on: https://github.com/echasnovski/mini.deps/blob/main/lua/mini/deps.lua
    -- Execute 'after/' scripts if not during startup (when they will be sourced
    -- automatically), as `:packadd` only sources plain 'plugin/' files.
    -- See https://github.com/vim/vim/issues/1994.
    -- Deliberately do so after executing all currently known 'plugin/' files.
    local should_load_after_dir = vim.v.vim_did_enter == 1 and vim.o.loadplugins
    if not should_load_after_dir then return 0 end
    -- NOTE: This sources first lua and then vim, not how it is done during
    -- startup (`:h loadplugins`) for speed (one `glob()` instead of two).
    local after_paths = vim.api.nvim_get_runtime_file("after/plugin/" .. fpattern, true)
    vim.tbl_map(function(f) vim.cmd("source " .. vim.fn.fnameescape(f)) end, after_paths)
    return #after_paths
end

require("pde.lazy").make_lazy_load("cmp", "InsertEnter", function()
    local main_plugins = { "luasnip", "nvim-cmp" }
    for _, plug in ipairs(main_plugins) do
        vim.cmd.packadd(plug)
    end

    local source_plugins = { "cmp_luasnip", "cmp-buffer", "cmp-path", "cmp-nvim-lsp" }
    for _, plug in ipairs(source_plugins) do
        vim.cmd.packadd(plug)
    end

    local after_sourced = load_after_plugin("cmp*.lua")
    if after_sourced ~= #source_plugins then
        vim.notify(
            "expected "
                .. #source_plugins
                .. " cmp source after/plugin sources, but got "
                .. after_sourced,
            vim.log.levels.WARN
        )
    end

    require("pde.cmp").setup()
end)
