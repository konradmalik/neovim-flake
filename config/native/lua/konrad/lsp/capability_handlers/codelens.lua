local codelens_is_enabled = true;
local keymapper = require('konrad.lsp.keymapper')

local M = {}

---@param data table
---@return table of commands and buf_commands for this client
M.setup = function(data)
    local augroup = data.augroup
    local bufnr = data.bufnr

    -- refresh now as well
    vim.lsp.codelens.refresh()

    vim.api.nvim_create_user_command("CodeLensToggle",
        function()
            codelens_is_enabled = not codelens_is_enabled
            if not codelens_is_enabled then
                vim.lsp.codelens.clear()
            end
            print('Setting codelens to: ' .. tostring(codelens_is_enabled))
        end, {
            desc = "Enable/disable codelens with lsp",
        })

    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost' }, {
        group = augroup,
        buffer = bufnr,
        callback = function()
            if codelens_is_enabled then
                vim.lsp.codelens.refresh()
            end
        end,
        desc = "Refresh codelens",
    })

    local opts_with_desc = keymapper.setup(bufnr)

    vim.api.nvim_buf_create_user_command(bufnr, "CodeLensRefresh", vim.lsp.codelens.refresh,
        { desc = 'Refresh codelens for the current buffer' })
    vim.keymap.set("n", "<leader>cl", vim.lsp.codelens.run, opts_with_desc("CodeLens run"))

    return {
        commands = { "CodeLensToggle" },
        buf_commands = { "CodeLensRefresh" },
    }
end

return M
