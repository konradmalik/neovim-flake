local M = {}

---@type fun(): integer
function M.stwinnr() return vim.g.statusline_winid end

---@type fun(): integer
function M.stbufnr() return vim.api.nvim_win_get_buf(M.stwinnr()) end

return M
