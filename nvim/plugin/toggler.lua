---@param fallback string
local function toggle_or(fallback)
    return function() return require("pde.toggler").toggle_or(fallback) end
end

vim.keymap.set("n", "<C-a>", toggle_or("<C-a>"), { expr = true, desc = "Toggle word or increment" })
vim.keymap.set("n", "<C-x>", toggle_or("<C-x>"), { expr = true, desc = "Toggle word or decrement" })
