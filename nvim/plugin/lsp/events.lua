local group = vim.api.nvim_create_augroup("personal-lsp", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
    group = group,
    callback = function(args)
        local client_id = args.data.client_id
        local client = vim.lsp.get_client_by_id(client_id)
        if client then
            require("pde.lsp").attach(client, args.buf)
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
            require("pde.lsp").detach(client, args.buf)
        else
            vim.notify("cannot find client " .. client_id, vim.log.levels.ERROR)
        end
    end,
})
