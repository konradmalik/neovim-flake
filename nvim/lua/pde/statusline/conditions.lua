local M = {}

---@return boolean
function M.is_activewin() return vim.api.nvim_get_current_win() == vim.g.statusline_winid end

return M
