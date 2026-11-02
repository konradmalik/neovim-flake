local method = "textDocument/documentHighlight"
local enabled = true

-- global autocmds, so there is nothing to set up or clean up per buffer
local augroup = vim.api.nvim_create_augroup("pde-lsp-document-highlight", { clear = true })

vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
    group = augroup,
    callback = function(args)
        if enabled and next(vim.lsp.get_clients({ bufnr = args.buf, method = method })) then
            vim.lsp.buf.document_highlight()
        end
    end,
    desc = "Highlight references when cursor holds",
})

vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    group = augroup,
    -- not limited to supporting buffers, so highlights left by a detached client go away too
    callback = function(args) vim.lsp.util.buf_clear_references(args.buf) end,
    desc = "Clear references when cursor moves",
})

---@type pde.lsp.Toggle
return {
    enable = function(enable)
        enabled = enable ~= false
        if enabled then return end
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            vim.lsp.util.buf_clear_references(buf)
        end
    end,
    is_enabled = function() return enabled end,
}
