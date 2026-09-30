-- all lsp keymaps are normal mode and carry this prefix, so clear() can find them
local prefix = "[LSP] "

---@class pde.lsp.keymapper
local M = {}

---@param bufnr integer
---@param lhs string
---@param rhs string|function
---@param desc string
function M.set(bufnr, lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = prefix .. desc }) end

---@param bufnr integer
---@param lhs string
function M.del(bufnr, lhs) pcall(vim.keymap.del, "n", lhs, { buffer = bufnr }) end

---@param bufnr integer
function M.clear(bufnr)
    for _, keymap in ipairs(vim.api.nvim_buf_get_keymap(bufnr, "n")) do
        if vim.startswith(keymap.desc or "", prefix) then M.del(bufnr, keymap.lhs) end
    end
end

return M
