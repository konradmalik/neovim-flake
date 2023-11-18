local inlayhints_is_enabled = true

local M = {}

---@param data table
---@return table of commands and buf_commands for this client
M.attach = function(data)
    local bufnr = data.bufnr

    vim.api.nvim_create_autocmd({ "InsertEnter" }, {
        callback = function()
            if not inlayhints_is_enabled then
                return
            end
            vim.lsp.inlay_hint(bufnr, true)
        end,
    })
    vim.api.nvim_create_autocmd({ "InsertLeave" }, {
        callback = function()
            if not inlayhints_is_enabled then
                return
            end
            pcall(vim.lsp.inlay_hint, bufnr, false)
        end,
    })

    vim.api.nvim_create_user_command("InlayHintsToggle", function()
        inlayhints_is_enabled = not inlayhints_is_enabled
        print("Setting inlayhints to: " .. tostring(inlayhints_is_enabled))
    end, {
        desc = "Enable/disable inlayhints with lsp",
    })

    return {
        commands = { "InlayHintsToggle" },
    }
end

return M
