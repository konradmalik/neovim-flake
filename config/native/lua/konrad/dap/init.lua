local M = {}

local reinitialize_needed = false
local configs = {}

--- Configure DAP by name, useful for per-project .nvim.lua files.
--- Must be called before init. This works because I don't initialize DAP
---at start, but on demand via DapEnable command.
---
---Built-in names:
---      - cs
---      - go
---      - python
--- If anything else, a whole configuration function needs to be provided.
---
---@param config string|function config name or function with no arguments if custom config
---@return nil
M.add = function(config)
    table.insert(configs, config)
end
--
-- safe to call this many times, eg. from .nvim.lua on sourcing it manually
-- placed in .nvim.lua won't be called before setup, due to reinitialize_needed==false
M.initialize = function(force)
    if force or reinitialize_needed then
        if not vim.tbl_isempty(configs) then
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

-- main entrypoint. Should be called after .nvim.lua
-- this will happen if this is called in 'after' folder (and it is -> lsp.lua)
M.setup = function()
    M.initialize(true)
    reinitialize_needed = true
end

return M
