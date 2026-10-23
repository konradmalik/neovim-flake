local group = vim.api.nvim_create_augroup("pde.progress", { clear = true })
vim.api.nvim_create_autocmd("LspProgress", {
    group = group,
    callback = function(args)
        ---@type lsp.WorkDoneProgressBegin|lsp.WorkDoneProgressReport|lsp.WorkDoneProgressEnd
        local progress = args.data.params.value
        if type(progress) ~= "table" then return end

        local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
        local done = progress.kind == "end"

        vim.api.nvim_echo({ { progress.message or (done and "done" or "") } }, false, {
            kind = "progress",
            id = "lsp." .. args.data.client_id .. "." .. args.data.params.token,
            source = "vim.lsp",
            title = progress.title and client.name .. ": " .. progress.title or client.name,
            status = done and "success" or "running",
            percent = progress.percentage,
        })
    end,
})
