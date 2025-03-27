vim.api.nvim_create_autocmd("LspDetach", {
    group = vim.api.nvim_create_augroup("personal-lsp-stop-if-last", { clear = true }),
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then return end

        for buf_id in pairs(client.attached_buffers) do
            -- we're detaching from args.buf
            -- so if we have at least one buffer that's not it, we should not stop
            if buf_id ~= args.buf then return end
        end
        client:stop()
    end,
    desc = "Stop lsp client when no buffer is attached",
})
