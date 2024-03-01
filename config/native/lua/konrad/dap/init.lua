local initialized = false
local initialize_once = function()
    if initialized then return end

    vim.cmd("packadd nvim-dap")
    vim.cmd("packadd nvim-dap-ui")
    vim.cmd("packadd nvim-dap-virtual-text")

    require("konrad.dap.ui")
    require("konrad.dap.virtual-text")
    require("konrad.dap.keymaps")

    initialized = true
end

local M = {}

--- Configure DAP by name
---
---Built-in names
---      - cs
---      - go
---      - python
--- If anything else, a whole configuration function needs to be provided.
---
---@param dap string|function - dap config name or a function that configures it
---@return nil
M.init = function(dap)
    initialize_once()

    if type(dap) == "string" then
        local found, _ = pcall(require, "konrad.dap.configs." .. dap)
        if not found then vim.notify("could not find DAP config for " .. dap) end
    elseif type(dap) == "function" then
        dap()
    else
        vim.notify("bad type for dap config: " .. vim.inspect(dap), vim.log.levels.ERROR)
    end
end

return M
