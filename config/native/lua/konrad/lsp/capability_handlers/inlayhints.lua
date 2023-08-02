local inlayhints_is_enabled = true;

local M = {}

---@param data table
---@return table of commands and buf_commands for this client
M.attach = function(data)
    local bufnr = data.bufnr
    local client = data.client

    vim.cmd('packadd lsp-inlayhints.nvim')
    local inlayhints = require('lsp-inlayhints')
    inlayhints.setup({ enabled_at_startup = inlayhints_is_enabled })
    inlayhints.on_attach(client, bufnr)

    vim.api.nvim_create_user_command("InlayHintsToggle",
        function()
            inlayhints_is_enabled = not inlayhints_is_enabled
            inlayhints.toggle()
            if inlayhints_is_enabled then
                inlayhints.show()
            else
                inlayhints.reset()
            end
            print('Setting inlayhints to: ' .. tostring(inlayhints_is_enabled))
        end, {
            desc = "Enable/disable inlayhints with lsp",
        })

    return {
        commands = { "InlayHintsToggle" },
    }
end

M.detach = function()
    require('lsp-inlayhints').reset()
end

return M
