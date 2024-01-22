local M = {}

function M.stwinnr() return vim.g.statusline_winid end

function M.stbufnr() return vim.api.nvim_win_get_buf(M.stwinnr()) end

return M
