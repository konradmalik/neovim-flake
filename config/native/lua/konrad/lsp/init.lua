local utils = require('konrad.utils')
-- if add is called rather late, after the file is opened, then the configured server won't start for the current buffer
-- solution is to check if we currently have a buffer and if it matches the configured filetype
-- will also restart if the server is already started, because it's config most probably changed (useful for eg. when
-- manually sourcing .nvim.lua or similar)
---@param config table
---@return nil
local start_if_needed = function(config)
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


local local_lsps = {}
local init_lsps = function()
    local additional = local_lsps
    for k, v in pairs(additional) do
        init_lspconfig(k, v)
    end
end

local local_efm_plugins = {}
local init_efm = function()
    local efm = require("konrad.lsp.efm")
    local additional = local_efm_plugins
    local config = efm.config_for(vim.list_extend(additional, efm.default_plugins))
    init_lspconfig("efm", config)
end

local reinitialize_needed = false
local initialize = function(force)
    if force or reinitialize_needed then
        init_efm()
        init_lsps()
    end
end

local M = {}

---@param tconfigs table of server-value mapping
--- server: any server name from nvim-lspconfig or 'efm' if this enables an efm plugin.
--- value:
--- server == 'lsp' -> options you would pass to lspconfig.setup(opts), will override base settings
--- server == 'efm' -> a list of plugins to enable eg. {'black'} (some plugins are always enabled).
---@return nil
M.setup = function(tconfigs)
    local_efm_plugins = {}
    local_lsps = {}
    for server, value in pairs(tconfigs) do
        if type(server) == "number" then
            server = value
            value = nil
        end

        if server == 'efm' then
            local_efm_plugins = value
        else
            local_lsps[server] = value or {}
        end
    end

    -- if this is called from config, won't do anything
    -- if this is called via sourcing .nvim.lua (after our 'after' folder) it should act
    initialize(false)
end

-- call this after .nvim.lua (from after folder eg.)
M.initialize = function()
    require("konrad.lsp.attach")
    require("konrad.lsp.fidget")
    initialize(true)
    reinitialize_needed = true
end

return M
