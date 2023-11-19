local highlight_is_enabled = true

local M = {}

---@param data table
---@return table of commands and buf_commands for this client
M.attach = function(data)
    local augroup = data.augroup
    local bufnr = data.bufnr

    vim.api.nvim_create_user_command("DocumentHighlightToggle", function()
        highlight_is_enabled = not highlight_is_enabled
        if not highlight_is_enabled then
            vim.lsp.buf.clear_references()
        end
        print("Setting document highlight to: " .. tostring(highlight_is_enabled))
    end, {
        desc = "Enable/disable highlight word under cursor with lsp",
    })

    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        group = augroup,
        buffer = bufnr,
        callback = function()
            if not highlight_is_enabled then
                return
            end
            vim.schedule(vim.lsp.buf.document_highlight)
        end,
        desc = "Highlight references when cursor holds",
    })

    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = augroup,
        buffer = bufnr,
        callback = function()
            if not highlight_is_enabled then
                return
            end
            vim.schedule(vim.lsp.buf.clear_references)
        end,
        desc = "Clear references when cursor moves",
    })

    return {
        commands = { "DocumentHighlightToggle" },
    }
end

M.detach = function()
    vim.schedule(vim.lsp.buf.clear_references)
end

return M
