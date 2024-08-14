local autostart_enabled = true

---useful for example when deciding if to attach LSP client to that buffer
---@param bufnr integer buffer to check. 0 for current
---@return boolean true if the buffer represents a real, readable file
local function is_buf_readable_file(bufnr)
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    return vim.fn.filereadable(bufname) == 1
end

local M = {}

M.toggle_autostart = function() autostart_enabled = not autostart_enabled end

function M.is_autostart_enabled() return autostart_enabled end

---Same arguments as vim.lsp.start
--- @param config vim.lsp.ClientConfig Configuration for the server.
--- @param opts vim.lsp.start.Opts? Optional keyword arguments
--- @return integer? client_id
function M.start(config, opts)
    if not autostart_enabled then
        vim.notify_once("LSP autostart is disabled", vim.log.levels.INFO)
        return
    end

    opts = opts or {}
    opts.bufnr = opts.bufnr or vim.api.nvim_get_current_buf()

    if not is_buf_readable_file(opts.bufnr) then return end

    local made_config = require("pde.lsp.capabilities").merge_capabilities(config)

    if not made_config.root_dir then made_config.root_dir = vim.uv.os_tmpdir() end

    local client_id = vim.lsp.start(made_config, opts)
    if not client_id then
        vim.notify("cannot start lsp: " .. made_config.cmd[1], vim.log.levels.WARN)
    end
    return client_id
end

function M.initialize_once()
    require("pde.lsp.commands")

    require("pde.lsp.progress")
    local group = vim.api.nvim_create_augroup("personal-lsp", { clear = true })

    vim.api.nvim_create_autocmd("LspAttach", {
        group = group,
        callback = function(args)
            local client_id = args.data.client_id
            local client = vim.lsp.get_client_by_id(client_id)
            local bufnr = args.buf
            if client then
                require("pde.lsp.event_handlers").attach(client, bufnr)
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
                require("pde.lsp.event_handlers").detach(client, bufnr)
            else
                vim.notify("cannot find client " .. client_id, vim.log.levels.ERROR)
            end
        end,
    })
end

return M
