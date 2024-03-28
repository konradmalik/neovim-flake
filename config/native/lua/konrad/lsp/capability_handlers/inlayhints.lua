local inlayhints_is_enabled = true

---@type CapabilityHandler
return {
    attach = function(data)
        local bufnr = data.bufnr
        local augroup = data.augroup

        vim.api.nvim_create_autocmd("InsertEnter", {
            group = augroup,
            buffer = bufnr,
            callback = function(args)
                if not inlayhints_is_enabled then return end
                vim.lsp.inlay_hint.enable(args.bufnr, true)
            end,
        })
        vim.api.nvim_create_autocmd("InsertLeave", {
            group = augroup,
            buffer = bufnr,
            callback = function(args)
                if not inlayhints_is_enabled then return end
                pcall(vim.lsp.inlay_hint.enable, args.bufnr, false)
            end,
        })

        vim.api.nvim_buf_create_user_command(bufnr, "InlayHintsToggle", function()
            inlayhints_is_enabled = not inlayhints_is_enabled
            if not inlayhints_is_enabled then
                for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                    pcall(vim.lsp.inlay_hint.enable, buf, false)
                end
            end
            print("Setting inlayhints to: " .. tostring(inlayhints_is_enabled))
        end, {
            desc = "Enable/disable inlayhints with lsp",
        })
    end,

    detach = function(_, bufnr)
        pcall(vim.lsp.inlay_hint.enable, bufnr, false)
        vim.api.nvim_buf_del_user_command(bufnr, "InlayHintsToggle")
    end,
}
