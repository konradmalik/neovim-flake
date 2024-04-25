local initialized = false
local initialize_once = function()
    if initialized then return end

    vim.cmd.packadd("nvim-dap")
    -- nio is a dependency of nvim-dap-ui
    vim.cmd.packadd("nvim-nio")
    vim.cmd.packadd("nvim-dap-ui")
    vim.cmd.packadd("nvim-dap-virtual-text")

    require("pde.dap.ui")
    require("pde.dap.virtual-text")
    require("pde.dap.keymaps")

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
        local found, _ = pcall(require, "pde.dap.configs." .. dap)
        if not found then vim.notify("could not find DAP config for " .. dap) end
    elseif type(dap) == "function" then
        dap()
    else
        vim.notify("bad type for dap config: " .. vim.inspect(dap), vim.log.levels.ERROR)
    end
end

return M
