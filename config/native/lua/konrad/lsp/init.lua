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
    local efm = require('konrad.lsp.efm')
    local config = efm.build_lspconfig(vim.list_extend(local_efm_plugins, efm.default_plugins))
    init_lspconfig("efm", config)
end

local already_setup = false
local initialize = function()
    if already_setup then
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
    initialize()
end

-- call this after .nvim.lua (from after folder eg.)
M.initialize = function()
    already_setup = true
    initialize()
end

return M
