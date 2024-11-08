---@diagnostic disable-next-line: duplicate-set-field
vim.ui.input = function(opts, on_confirm)
    opts = opts or {}
    require("pde.floating-input").input(opts, on_confirm, {})
end
