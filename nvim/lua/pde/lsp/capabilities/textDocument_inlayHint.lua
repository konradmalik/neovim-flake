vim.g.inlayhints_enabled = false

---@type CapabilityHandler
return {
    attach = function(data)
        local bufnr = data.bufnr

        vim.api.nvim_buf_create_user_command(bufnr, "InlayHintsToggle", function()
            vim.g.inlayhints_enabled = not vim.g.inlayhints_enabled
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                vim.lsp.inlay_hint.enable(vim.g.inlayhints_enabled, { bufnr = buf })
            end
            vim.notify(
                "Setting inlayhints to: " .. tostring(vim.g.inlayhints_enabled),
                vim.log.levels.INFO
            )
        end, {
            desc = "Enable/disable inlayhints with lsp",
        })

        vim.lsp.inlay_hint.enable(vim.g.inlayhints_enabled, { bufnr = bufnr })
    end,

    detach = function(_, bufnr)
        vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
        vim.api.nvim_buf_del_user_command(bufnr, "InlayHintsToggle")
    end,
}
