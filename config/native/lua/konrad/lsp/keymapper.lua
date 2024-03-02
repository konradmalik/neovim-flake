local keymap_prefix = "[LSP]"

local M = {}

M.prefix = keymap_prefix

---@param bufnr integer
---@return fun(string): table
M.opts_for = function(bufnr)
    return function(desc) return { buffer = bufnr, desc = keymap_prefix .. " " .. desc } end
end

---@param bufnr integer
M.clear = function(bufnr)
    for _, mode in ipairs({ "n", "i", "v" }) do
        local keymaps = vim.api.nvim_buf_get_keymap(bufnr, mode)
        for _, keymap in ipairs(keymaps) do
            if keymap.desc then
                if vim.startswith(keymap.desc, M.prefix) then
                    pcall(vim.api.nvim_buf_del_keymap, bufnr, mode, keymap.lhs)
                end
            end
        end
    end
end

return M
