require("konrad.lsp").initialize()

local lsp = require("konrad.lsp.event_handlers")

---@param client table
---@param bufnr number
local on_attach = function(client, bufnr)
    -- vim.notify("attaching lsp client " .. client.name .. " (" .. client.id .. ") to buf " .. bufnr, vim.log.levels.DEBUG)
    lsp.attach(client, bufnr)
end

---@param client table
---@param bufnr number
local on_detach = function(client, bufnr)
    -- vim.notify("detaching lsp client " .. client.name .. " (" .. client.id .. ") from buf " .. bufnr, vim.log.levels.DEBUG)
    lsp.detach(client, bufnr)
end

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('personal-lsp-attach', { clear = true }),
    callback = function(args)
        local client_id = args.data.client_id
        local client = vim.lsp.get_client_by_id(client_id)
        local bufnr = args.buf
        on_attach(client, bufnr)
    end,
})

vim.api.nvim_create_autocmd('LspDetach', {
    group = vim.api.nvim_create_augroup('personal-lsp-detach', { clear = true }),
    callback = function(args)
        local client_id = args.data.client_id
        local client = vim.lsp.get_client_by_id(client_id)
        local bufnr = args.buf
        on_detach(client, bufnr)
    end,
})
