local utils = require('konrad.utils')
-- if add is called rather late, after the file is opened, then the configured server won't start for the current buffer
-- solution is to check if we currently have a buffer and if it matches the configured filetype
-- will also restart if the server is already started, because it's config most probably changed (useful for eg. when
-- manually sourcing .nvim.lua or similar)
---@param config table
---@return nil
local function start_if_needed(config)
    -- if attached, restart because config changed
    local clients = vim.lsp.get_active_clients(config)
    if #clients > 0 then
        local client = clients[1]
        vim.lsp.stop_client(client.id)
    end
    -- launch if matching filetype
    if utils.is_matching_filetype(config) then
        config.launch()
    end
end

local init_lspconfig = function(server, opts)
    local lspconfig = require("lspconfig")
    local capabilities = require("konrad.lsp.capabilities")

    local found, overrides = pcall(require, "konrad.lsp.settings." .. server)
    if not found then
        overrides = {}
    end

    local base = {
        capabilities = capabilities,
    }

    local merged = vim.tbl_deep_extend("force", base, overrides, opts or {})
    local config = lspconfig[server]
    config.setup(merged)
    start_if_needed(config)
end


-- added via .nvim.lua
local local_lsps = {}
local init_lsps = function()
    local additional = local_lsps
    for k, v in pairs(additional) do
        init_lspconfig(k, v)
    end
end

-- added via .nvim.lua
local local_efm_plugins = {}
local init_efm = function()
    local efm = require("konrad.lsp.efm")
    local additional = local_efm_plugins
    local config = efm.config_for(vim.list_extend(additional, efm.default_plugins))
    init_lspconfig("efm", config)
end

local M = {}
local reinitialize_needed = false

---@param server string
-- any server name from nvim-lspconfig or 'efm' if this enables an efm plugin.
---@param value any
--- server == 'lsp' -> options you would pass to lspconfig.setup(opts), will override base settings
--- server == 'efm' -> a list of plugins to enable eg. {'black'} (some plugins are always enabled).
---@return nil
M.add = function(server, value)
    if server == 'efm' then
        local_efm_plugins = value
        return
    else
        local_lsps[server] = value or {}
        return
    end
end

-- safe to call this many times, eg. from .nvim.lua on sourcing it manually
-- placed in .nvim.lua won't be called before setup, due to reinitialize_needed==false
M.initialize = function(force)
    if force or reinitialize_needed then
        init_efm()
        init_lsps()
    end
end

-- main entrypoint. Should be called after .nvim.lua
-- this will happen if this is called in 'after' folder (and it is -> lsp.lua)
M.setup = function()
    require("konrad.lsp.attach")
    require("konrad.lsp.fidget")
    M.initialize(true)
    reinitialize_needed = true
end

return M
