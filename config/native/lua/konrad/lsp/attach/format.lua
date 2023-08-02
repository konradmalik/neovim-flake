local format_is_enabled = true;

local M = {}

---@param augroup integer
---@param client table
---@param bufnr integer
---@return table of commands and buf_commands for this client
M.attach = function(augroup, client, bufnr)
    vim.api.nvim_create_user_command("AutoFormatToggle",
        function()
            format_is_enabled = not format_is_enabled
            print('Setting autoformatting to: ' .. tostring(format_is_enabled))
        end, {
            desc = "Enable/disable autoformat with lsp",
        })

    vim.api.nvim_create_autocmd('BufWritePre', {
        desc = "AutoFormat on save",
        group = augroup,
        buffer = bufnr,
        callback = function()
            P("format_is_enabled " .. tostring(format_is_enabled))
            if format_is_enabled then
                P('formatting')
                vim.lsp.buf.format({
                    async = false,
                    id = client.id,
                    bufnr = bufnr,
                })
            end
        end,
    })

    vim.api.nvim_buf_create_user_command(bufnr, "Format",
        function()
            vim.lsp.buf.format({
                async = false,
                id = client.id,
                bufnr = bufnr,
            })
        end,
        { desc = 'Format current buffer with LSP' })

    return {
        commands = { "AutoFormatToggle" },
        buf_commands = { "Format" },
    }
end

return M
