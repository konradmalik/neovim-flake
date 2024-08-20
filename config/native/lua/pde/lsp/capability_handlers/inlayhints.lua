local inlayhints_is_enabled = true

---@type CapabilityHandler
return {
    attach = function(data)
        local bufnr = data.bufnr

        vim.api.nvim_buf_create_user_command(bufnr, "InlayHintsToggle", function()
            inlayhints_is_enabled = not inlayhints_is_enabled
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                vim.lsp.inlay_hint.enable(inlayhints_is_enabled, { bufnr = buf })
            end
            print("Setting inlayhints to: " .. tostring(inlayhints_is_enabled))
        end, {
            desc = "Enable/disable inlayhints with lsp",
        })

        if inlayhints_is_enabled then vim.lsp.inlay_hint.enable(true, { bufnr = bufnr }) end
    end,

    detach = function(_, bufnr)
        vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
        vim.api.nvim_buf_del_user_command(bufnr, "InlayHintsToggle")
    end,
}
