local utils = {}

---@param ... string
---@return boolean
function utils.has_bins(...)
    for i = 1, select("#", ...) do
        if 0 == vim.fn.executable((select(i, ...))) then
            return false
        end
    end
    return true
end

---@param name string
---@param packadds string[]
---@param fun function
---@param opts table|nil
function utils.make_enable_command(name, packadds, fun, opts)
    vim.api.nvim_create_user_command(name, function()
        vim.api.nvim_del_user_command(name)
        for _, value in ipairs(packadds) do
            vim.cmd('packadd ' .. value)
        end
        fun()
    end, opts or {});
end

--
---@param packadd string | string[] run packadd on those strings, usually package names
---@param fun function? execute after loading
---@param event string? | string[] event or events to load on
---@param ft string? | string[] filetype patterns to load on
function utils.lazy_load(packadd, fun, event, ft)
    local group = vim.api.nvim_create_augroup("lazy-load", { clear = false })
    vim.api.nvim_create_autocmd(event or 'UIEnter', {
        group = group,
        pattern = ft or '*',
        callback = function(args)
            -- args: id, event, group, match, buf, file, data
            if (type(packadd) == "table") then
                for _, value in ipairs(packadd) do
                    vim.cmd('packadd ' .. value)
                end
            else
                vim.cmd('packadd ' .. packadd)
            end
            if fun then
                fun()
            end
        end,
        desc = "Lazily initialize " .. vim.inspect(packadd),
        once = true,
    })
end

---@param config table Can be obtained by getting the 'client' object in some way and calling 'client.config'
---@return boolean
function utils.is_matching_filetype(config)
    local ft = vim.bo.filetype or ''
    return ft ~= '' and vim.tbl_contains(config.filetypes or {}, ft)
end

return utils
