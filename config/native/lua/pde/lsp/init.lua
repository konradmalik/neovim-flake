local M = {}

---@class LspConfig
---@field enabled_configs string[] list of config names from {rtp}/lsp/*.lua

---Initialize lsp configurations
---@param config LspConfig
function M.setup(config)
    require("pde.lsp.commands")

    require("pde.lsp.progress")
    local group = vim.api.nvim_create_augroup("personal-lsp", { clear = true })

    vim.api.nvim_create_autocmd("LspAttach", {
        group = group,
        callback = function(args)
            local client_id = args.data.client_id
            local client = vim.lsp.get_client_by_id(client_id)
            if client then
                require("pde.lsp.event_handlers").attach(client, args.buf)
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
            if client then
                require("pde.lsp.event_handlers").detach(client, args.buf)
            else
                vim.notify("cannot find client " .. client_id, vim.log.levels.ERROR)
            end
        end,
    })

    vim.lsp.config("*", {
        root_markers = {
            ".git",
        },
    })

    for _, name in ipairs(config.enabled_configs or {}) do
        vim.lsp.enable(name, true)
    end
end

return M
