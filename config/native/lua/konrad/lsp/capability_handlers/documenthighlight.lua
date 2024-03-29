local highlight_is_enabled = true

---@type CapabilityHandler
return {
    attach = function(data)
        local augroup = data.augroup
        local bufnr = data.bufnr

        vim.api.nvim_buf_create_user_command(bufnr, "DocumentHighlightToggle", function()
            highlight_is_enabled = not highlight_is_enabled
            if not highlight_is_enabled then vim.lsp.buf.clear_references() end
            print("Setting document highlight to: " .. tostring(highlight_is_enabled))
        end, {
            desc = "Enable/disable highlight word under cursor with lsp",
        })

        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            group = augroup,
            buffer = bufnr,
            callback = function()
                if not highlight_is_enabled then return end
                vim.lsp.buf.document_highlight()
            end,
            desc = "Highlight references when cursor holds",
        })

        vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            group = augroup,
            buffer = bufnr,
            callback = function()
                if not highlight_is_enabled then return end
                vim.lsp.buf.clear_references()
            end,
            desc = "Clear references when cursor moves",
        })
    end,

    detach = function(_, bufnr)
        pcall(vim.lsp.buf.clear_references)
        vim.api.nvim_buf_del_user_command(bufnr, "DocumentHighlightToggle")
    end,
}
