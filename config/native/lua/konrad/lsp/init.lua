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
local local_nullls_sources_fun
local init_null_ls = function()
    if local_nullls_sources_fun then
        local null = require('null-ls')
        local additional = local_nullls_sources_fun(null)
        null.register(additional)
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
-- any server name from nvim-lspconfig or 'null-ls' if this adds a null-ls source, of 'efm' if this
-- enables an efm plugin.
---@param value any
--- server == 'lsp' -> options you would pass to lspconfig.setup(opts), will override base settings
--- server == 'efm' -> a list of plugins to enable eg. {'black'} (some plugins are always enabled).
--  server == 'null-ls' -> a function which takes null-ls and returns a list of sources to enable (some sources are always enabled)
---@return nil
M.add = function(server, value)
    if server == 'null-ls' then
        local_nullls_sources_fun = value
        return
    elseif server == 'efm' then
        local_efm_plugins = value
        return
    else
        local_lsps[server] = value or {}
        return
    end
end

-- safe to call this many times, eg. from .nvim.lua on sourcing it manually
M.initialize = function(force)
    if force or reinitialize_needed then
        init_null_ls()
        --init_efm()
        init_lsps()
    end
end

M.setup = function()
    utils.lazy_load({ "j-hui", "null-ls.nvim", "nvim-lspconfig" },
        function()
            require("konrad.lsp.attach")
            require("konrad.lsp.fidget")
            require("konrad.lsp.null-ls")
            M.initialize(true)
            reinitialize_needed = true
        end,
        { "BufReadPre", "BufNewFile" }
    )
end

return M
