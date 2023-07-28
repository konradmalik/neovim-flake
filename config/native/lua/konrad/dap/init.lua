local configs = {}
local reinitialize_needed = false

local initialize = function(force)
    if not vim.tbl_isempty(configs) then
        if force or reinitialize_needed then
            vim.cmd('packadd nvim-dap')
            vim.cmd('packadd nvim-dap-ui')
            vim.cmd('packadd nvim-dap-virtual-text')

            require("konrad.dap.ui")
            require("konrad.dap.virtual-text")
            require("konrad.dap.keymaps")

            for _, config in ipairs(configs) do
                if type(config) == "string" then
                    local found, _ = pcall(require, "konrad.dap.configurations." .. config)
                    if not found then
                        vim.notify("could not find DAP config for " .. config)
                    end
                elseif type(config) == "function" then
                    config()
                else
                    vim.notify("bad type for config: " .. vim.inspect(config))
                end
            end
        end
    end
end

local M = {}

--- Configure DAP by name, useful for per-project .nvim.lua files.
---
---Built-in names:
---      - cs
---      - go
---      - python
--- If anything else, a whole configuration function needs to be provided.
---
---@param tconfigs table (array-like) of string|function - dap config name or function with no arguments if custom config
---@return nil
M.setup = function(tconfigs)
    configs = {}
    for _, value in ipairs(tconfigs) do
        table.insert(configs, value)
    end

    -- if this is called from config, won't do anything
    -- if this is called via sourcing .nvim.lua (after our 'after' folder) it should act
    initialize(false)
end

-- call this after .nvim.lua (from after folder eg.)
M.initialize = function()
    initialize(true)
    reinitialize_needed = true
end

return M
