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
---@return integer
M.start_and_attach = function(config)
    initialize_once()

    local made_config = require("konrad.lsp.configs").make_config(config)
    local client_id = vim.lsp.start(made_config)
    if not client_id then
        vim.notify("cannot start lsp: " .. config.cmd, vim.log.levels.ERROR)
        return 0
    end
    vim.lsp.buf_attach_client(vim.api.nvim_get_current_buf(), client_id)
    return client_id
end

return M
