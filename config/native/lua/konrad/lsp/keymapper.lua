local keymap_prefix = "[LSP]"

local M = {}

M.prefix = keymap_prefix

M.setup = function(bufnr)
    local opts = { buffer = bufnr, noremap = true, silent = true }
    return function(desc)
        vim.tbl_extend("error", opts, { desc = keymap_prefix .. " " .. desc })
    end
end

return M
