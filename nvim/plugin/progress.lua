local group = vim.api.nvim_create_augroup("pde.progress", { clear = true })
vim.api.nvim_create_autocmd("LspProgress", {
    group = group,
    callback = function(args)
        ---@type lsp.WorkDoneProgressBegin|lsp.WorkDoneProgressReport|lsp.WorkDoneProgressEnd
        local progress = args.data.params.value

        vim.api.nvim_echo({ { progress.message or "done" } }, false, {
            kind = "progress",
            id = "lsp." .. args.data.client_id,
            source = "vim.lsp",
            title = progress.title,
            status = progress.kind ~= "end" and "running" or "success",
            percent = progress.percentage,
        })
    end,
})
