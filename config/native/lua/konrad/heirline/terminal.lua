local icons = require("konrad.icons")
local colors = require('konrad.heirline.colors')

local M = {}
M.TerminalName = {
    -- we could add a condition to check that buftype == 'terminal'
    -- or we could do that later (see #conditional-statuslines below)
    provider = function()
        local tname, _ = vim.api.nvim_buf_get_name(0):gsub(".*:", "")
        return icons.ui.Terminal .. tname
    end,
    hl = { fg = colors.blue, bold = true },
}
return M
