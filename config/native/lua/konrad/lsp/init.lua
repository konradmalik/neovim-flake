local initialized = false
local initialize_once = function()
    if initialized then
        return
    end

    require("konrad.lsp.borders")
    require("konrad.lsp.commands")

    vim.cmd("packadd fidget.nvim")
    require("konrad.lsp.fidget")

    vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("personal-lsp-attach", { clear = true }),
        callback = function(args)
            local client_id = args.data.client_id
            local client = vim.lsp.get_client_by_id(client_id)
            local bufnr = args.buf
            require("konrad.lsp.event_handlers").attach(client, bufnr)
        end,
    })

    vim.api.nvim_create_autocmd("LspDetach", {
        group = vim.api.nvim_create_augroup("personal-lsp-detach", { clear = true }),
        callback = function(args)
            local client_id = args.data.client_id
            local client = vim.lsp.get_client_by_id(client_id)
            local bufnr = args.buf
            require("konrad.lsp.event_handlers").detach(client, bufnr)
        end,
    })

    initialized = true
end

local M = {}

---starts if needed and attaches to the current buffer
---@param config table
---@param bufnr integer? buffer to attach to
M.start_and_attach = function(config, bufnr)
    initialize_once()

    local made_config = require("konrad.lsp.configs").make_config(config)
    local target_buf = bufnr or 0
    local client_id = vim.lsp.start(made_config, { bufnr = target_buf })
    if not client_id then
        vim.notify("cannot start lsp: " .. config.cmd[1], vim.log.levels.ERROR)
    end
end

return M
