local M = {}

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

return M
