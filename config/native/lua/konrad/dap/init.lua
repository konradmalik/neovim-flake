local configs = {}
local already_initialized = false

local initialize = function()
    already_initialized = true
    if not vim.tbl_isempty(configs) then
        vim.cmd("packadd nvim-dap")
        vim.cmd("packadd nvim-dap-ui")
        vim.cmd("packadd nvim-dap-virtual-text")

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

local M = {}

--- Configure DAP by name, useful for per-project .nvim.lua files.
---
---Built-in names:
---      - cs
---      - go
---      - python
--- If anything else, a whole configuration function needs to be provided.
---
---@param tconfigs string[]|function[] - dap config names or function with no arguments if custom config
---@return nil
M.setup = function(tconfigs)
    configs = {}
    for _, value in ipairs(tconfigs) do
        table.insert(configs, value)
    end

    if already_initialized then
        -- reinitialize essentially, this is useful mostly when sourcing .nvim.lua manually
        initialize()
    end
end

-- call this after .nvim.lua (from after folder eg.)
M.initialize = function()
    initialize()
end

return M
