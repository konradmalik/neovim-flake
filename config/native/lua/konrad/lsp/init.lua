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

local add_lspconfig = function(server, opts)
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

local add_null_ls = function(sources)
    require('null-ls').register(sources)
end

local add_efm = function(plugins)
    local config = require("konrad.lsp.efm").updated_config_for(plugins)
    add_lspconfig("efm", config)
end

local M = {}

--- Configure lsp server, useful for per-project .nvim.lua files.
--- Can be called whenever. Works for lsp and null-ls currently.
---
--- Common examples for LSP:
---      - ansiblels
---      - csharp_ls
---      - gopls
---      - jsonls
---      - nil_ls
---      - omnisharp
---      - pyright
---      - rust_analyzer
---      - lua_ls
---      - terraformls
---      - yamlls
---
--- Common examples for efm:
--       - {'black','isort'}
---
--- Common examples for null-ls:
---      - require('null-ls').builtins.formatting.black
---      - require('null-ls').builtins.formatting.isort
---      - require('null-ls').builtins.formatting.nixpkgs_fmt
---      - require('null-ls').builtins.formatting.terraform_fmt
---      - require('null-ls').builtins.diagnostics.mypy.with({
---            condition = function(utils)
---                return kutils.has_bins("mypy")
---            end
---        })
---      - require('null-ls').builtins.diagnostics.vale.with({
---            condition = function(utils)
---                return kutils.has_bins("vale")
---            end
---        })
---
---@param server string any server name from nvim-lspconfig or 'null-ls' if this adds a null-ls source.
---@param opts table|nil
--- options you would pass to lspconfig.setup(opts), will override base settings
--- or if server is 'efm', then a list of plugins, eg. {'black'} (some plugins are always enabled).
--  efm should only be called once! Can be called more, but next invocations will overwrite.
--- or if server is 'null-ls', then source(s) config as a table
---@return nil
M.add = function(server, opts)
    if server == 'null-ls' then
        add_null_ls(opts)
        return
    elseif server == 'efm' then
        add_efm(opts)
        return
    else
        add_lspconfig(server, opts)
        return
    end
end

M.setup = function()
    require("konrad.lsp.fidget")
    require("konrad.lsp.null-ls")
    -- add_efm({ "prettier", "jq", "shfmt", "shellcheck" })
    require("konrad.lsp.attach")
end

return M
