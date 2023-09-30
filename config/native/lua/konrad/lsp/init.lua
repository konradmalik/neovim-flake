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

---@param lsps table of server name->server config
local init_lsps = function(lsps)
    for k, v in pairs(lsps) do
        init_lspconfig(k, v)
    end
end

local extra_efm_plugins = {}
local initialized_efm = false

local M = {}
M.default_efm_plugins = { "prettier", "jq", "shfmt", "shellcheck" }

---@param tconfigs table of server-value mapping
--- server: any server name from nvim-lspconfig or 'efm' if this enables an efm plugin.
--- value:
--- server == 'lsp' -> options you would pass to lspconfig.setup(opts), will override base settings
--- server == 'efm' -> a list of plugins to enable eg. {'black'} (some plugins are always enabled).
---@return nil
M.setup = function(tconfigs)
    local lsps = {}
    for server, value in pairs(tconfigs) do
        if type(server) == "number" then
            server = value
            value = nil
        end

        if server == "efm" then
            extra_efm_plugins = value
        else
            lsps[server] = value or {}
        end
    end

    init_lsps(lsps)
    if initialized_efm then
        M.init_efm()
    end
end

M.init_efm = function()
    local efm = require("konrad.lsp.efm")
    local all_plugins = {}
    all_plugins = vim.list_extend(all_plugins, extra_efm_plugins)
    local config = efm.build_lspconfig(vim.list_extend(all_plugins, M.default_efm_plugins))
    init_lspconfig("efm", config)
    initialized_efm = true
end

return M
