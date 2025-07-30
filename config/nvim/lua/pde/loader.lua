vim.loader.enable()

---@type function[]
local on_reset = {}

vim.api.nvim_create_user_command("CacheReset", function()
    vim.loader.reset()
    for _, f in ipairs(on_reset) do
        f()
    end
end, { desc = "Reset vim.loader cache and do other maintenance tasks" })

local M = {}

---Add the given function to be run on each CacheReset command
---@param f function
function M.add_to_on_reset(f) table.insert(on_reset, f) end

return M
