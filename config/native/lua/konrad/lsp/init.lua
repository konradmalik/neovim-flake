local fs = require("konrad.fs")

local autostart_enabled = true

local initialized = false
local initialize_once = function()
    if initialized then return end

    require("konrad.lsp.borders")
    require("konrad.lsp.commands")

    require("konrad.lsp.progress")
    local group = vim.api.nvim_create_augroup("personal-lsp", { clear = true })

    vim.api.nvim_create_autocmd("LspAttach", {
        group = group,
        callback = function(args)
            local client_id = args.data.client_id
            local client = vim.lsp.get_client_by_id(client_id)
            local bufnr = args.buf
            if client then
                require("konrad.lsp.event_handlers").attach(client, bufnr)
            else
                vim.notify("cannot find client " .. client_id, vim.log.levels.ERROR)
            end
        end,
    })

    vim.api.nvim_create_autocmd("LspDetach", {
        group = group,
        callback = function(args)
            local client_id = args.data.client_id
            local client = vim.lsp.get_client_by_id(client_id)
            local bufnr = args.buf
            if client then
                require("konrad.lsp.event_handlers").detach(client, bufnr)
            else
                vim.notify("cannot find client " .. client_id, vim.log.levels.ERROR)
            end
        end,
    })

    initialized = true
end

---starts if needed and attaches to the current buffer
---respects LspAutostartToggle
---@param fconfig vim.lsp.ClientConfig | fun(): vim.lsp.ClientConfig
---@param bufnr integer buffer to attach to
local function start_and_attach(fconfig, bufnr)
    if not autostart_enabled then
        vim.notify_once("LSP autostart is disabled", vim.log.levels.INFO)
        return
    end

    if not fs.is_buf_readable_file(bufnr) then return end

    initialize_once()

    local config
    if type(fconfig) == "function" then
        config = fconfig()
    else
        config = fconfig
    end

    local made_config = require("konrad.lsp.configs").make_config(config)
    local client_id = vim.lsp.start(made_config, {
        bufnr = bufnr,
        reuse_client = function(client, conf)
            return client.name == conf.name and client.root_dir == conf.root_dir
        end,
    })
    if not client_id then
        vim.notify("cannot start lsp: " .. made_config.cmd[1], vim.log.levels.WARN)
    end
end

local M = {}

M.toggle_autostart = function() autostart_enabled = not autostart_enabled end

function M.is_autostart_enabled() return autostart_enabled end

---@param lsp_config {["config"]: fun(): vim.lsp.ClientConfig}
---@param bufnr integer|nil
function M.init(lsp_config, bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    start_and_attach(lsp_config.config, bufnr)
end

return M
