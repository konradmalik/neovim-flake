local keymap_prefix = "[LSP]"

local M = {}

M.prefix = keymap_prefix

M.setup = function(bufnr)
    local opts = { buffer = bufnr, noremap = true, silent = true }
    return function(desc)
        vim.tbl_extend("error", opts, { desc = keymap_prefix .. " " .. desc })
    end
end

M.clear = function(bufnr)
    for _, mode in ipairs({ 'n', 'i', 'v' }) do
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
