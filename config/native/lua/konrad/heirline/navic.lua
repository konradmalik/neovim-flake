local colors = require("konrad.heirline.colors")

local M = {}

-- The easy way.
-- navic is lazy, packadded when lsp attaches
M.NavicLite = {
    condition = function()
        local ok, navic = pcall(require, "nvim-navic")
        if not ok then
            return false
        end
        return navic.is_available()
    end,
    provider = function()
        return require("nvim-navic").get_location({ highlight = false, click = true, safe_output = true })
    end,
    hl = { fg = colors.gray },
    update = "CursorMoved",
}

M.NavicFlexible = { flexible = 3, M.NavicLite, { provider = "" } }

return M
