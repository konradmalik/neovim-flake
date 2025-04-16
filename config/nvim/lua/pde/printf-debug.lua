---@param string_fun fun(name: string): string
---@param var_fun fun(var: string): string
---@return string
local function get_logging_keys(string_fun, var_fun)
    return "yo" .. string_fun('"pa"') .. "o" .. var_fun("pa") .. ""
end

return {
    ---@param string_fun fun(name: string): string
    ---@param var_fun fun(var: string): string
    set_keymap = function(string_fun, var_fun)
        vim.keymap.set(
            "v",
            "<leader>cl",
            function() vim.fn.feedkeys(get_logging_keys(string_fun, var_fun)) end
        )
    end,
}
