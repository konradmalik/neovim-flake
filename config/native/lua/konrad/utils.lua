local M = {}

---@param name string
---@param packadds string[]
---@param fun function
---@param opts table|nil
function M.make_enable_command(name, packadds, fun, opts)
    vim.api.nvim_create_user_command(name, function()
        vim.api.nvim_del_user_command(name)
        for _, value in ipairs(packadds) do
            vim.cmd('packadd ' .. value)
        end
        fun()
    end, opts or {});
end

---@param config table Can be obtained by getting the 'client' object in some way and calling 'client.config'
---@return boolean
function M.is_matching_filetype(config)
    local ft = vim.bo.filetype or ''
    return ft ~= '' and vim.tbl_contains(config.filetypes or {}, ft)
end

return M
