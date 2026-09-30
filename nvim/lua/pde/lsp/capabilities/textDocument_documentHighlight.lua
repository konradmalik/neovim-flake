vim.g.documenthighlight_enabled = true

vim.api.nvim_create_user_command("DocumentHighlightToggle", function()
    vim.g.documenthighlight_enabled = not vim.g.documenthighlight_enabled
    if not vim.g.documenthighlight_enabled then
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            vim.lsp.util.buf_clear_references(buf)
        end
    end
    vim.notify("Setting document highlight to: " .. tostring(vim.g.documenthighlight_enabled), vim.log.levels.INFO)
end, {
    desc = "Enable/disable highlight word under cursor with lsp",
})

-- one set of autocmds per buffer, not per client: document_highlight() already asks all clients
local augroup = vim.api.nvim_create_augroup("pde-lsp-document-highlight", { clear = true })

---@type pde.lsp.Feature
return {
    attach = function(_, bufnr)
        vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })

        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            group = augroup,
            buffer = bufnr,
            callback = function()
                if vim.g.documenthighlight_enabled then vim.lsp.buf.document_highlight() end
            end,
            desc = "Highlight references when cursor holds",
        })

        vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            group = augroup,
            buffer = bufnr,
            callback = function() vim.lsp.util.buf_clear_references(bufnr) end,
            desc = "Clear references when cursor moves",
        })
    end,

    detach = function(_, bufnr)
        vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
        vim.lsp.util.buf_clear_references(bufnr)
    end,
}
