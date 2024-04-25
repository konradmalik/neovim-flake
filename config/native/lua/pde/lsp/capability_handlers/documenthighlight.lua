local highlight_is_enabled = true

local buf_clear_references = function(buf)
    vim.api.nvim_buf_call(buf, function() vim.lsp.buf.clear_references() end)
end

local buf_document_highlight = function(buf)
    vim.api.nvim_buf_call(buf, function() vim.lsp.buf.document_highlight() end)
end

---@type CapabilityHandler
return {
    attach = function(data)
        local augroup = data.augroup
        local bufnr = data.bufnr

        vim.api.nvim_buf_create_user_command(bufnr, "DocumentHighlightToggle", function()
            highlight_is_enabled = not highlight_is_enabled
            if not highlight_is_enabled then
                for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                    buf_clear_references(buf)
                end
            end
            print("Setting document highlight to: " .. tostring(highlight_is_enabled))
        end, {
            desc = "Enable/disable highlight word under cursor with lsp",
        })

        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            group = augroup,
            buffer = bufnr,
            callback = function()
                if not highlight_is_enabled then return end
                buf_document_highlight(bufnr)
            end,
            desc = "Highlight references when cursor holds",
        })

        vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            group = augroup,
            buffer = bufnr,
            callback = function()
                if not highlight_is_enabled then return end
                buf_clear_references(bufnr)
            end,
            desc = "Clear references when cursor moves",
        })
    end,

    detach = function(_, bufnr)
        buf_clear_references(bufnr)
        vim.api.nvim_buf_del_user_command(bufnr, "DocumentHighlightToggle")
    end,
}
