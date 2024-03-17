local M = {}

local source_file = function(path)
    pcall(function() vim.cmd("source " .. vim.fn.fnameescape(path)) end)
end

---@param name string
---@param packadds string[]
---@param fun function
---@param opts table|nil
function M.make_enable_command(name, packadds, fun, opts)
    vim.api.nvim_create_user_command(name, function()
        vim.api.nvim_del_user_command(name)
        for _, value in ipairs(packadds) do
            vim.cmd.packadd(value)
        end
        fun()
    end, opts or {})
end

---@param name string unique
---@param event string|string[] as in nvim_create_autocmd
---@param callback function|string as in nvim_create_autocmd
function M.make_lazy_load(name, event, callback)
    local group = vim.api.nvim_create_augroup(name, { clear = true })
    vim.api.nvim_create_autocmd(event, {
        group = group,
        -- this plugin creates hl groups which forces a redraw,
        -- which makes intro screen flicker
        desc = name .. " deferred load",
        once = true,
        callback = callback,
    })
end

---Loads all files from after/plugin directory starting with prefix
---but only if the proper phase.
---@param fpattern string filename pattern
function M.load_after_plugin(fpattern)
    -- Execute 'after/' scripts if not during startup (when they will be sourced
    -- automatically), as `:packadd` only sources plain 'plugin/' files.
    -- See https://github.com/vim/vim/issues/1994.
    -- Deliberately do so after executing all currently known 'plugin/' files.
    local should_load_after_dir = vim.v.vim_did_enter == 1 and vim.o.loadplugins
    if not should_load_after_dir then return end
    -- NOTE: This sources first lua and then vim, not how it is done during
    -- startup (`:h loadplugins`) for speed (one `glob()` instead of two).
    local after_paths = vim.api.nvim_get_runtime_file("after/plugin/" .. fpattern, true)
    vim.tbl_map(source_file, after_paths)
end

return M
