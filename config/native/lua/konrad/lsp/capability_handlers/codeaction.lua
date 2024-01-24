local lightbulb_is_enabled = false

local M = {}
M.name = "CodeActions"

---@param data table
---@return table of commands and buf_commands for this client
M.attach = function(data)
    local augroup = data.augroup
    local bufnr = data.bufnr

    local keymapper = require("konrad.lsp.keymapper")
    local opts_with_desc = keymapper.opts_for(bufnr)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts_with_desc("Code Action"))

    vim.api.nvim_buf_create_user_command(bufnr, "LightBulbToggle", function()
        lightbulb_is_enabled = not lightbulb_is_enabled
        if not lightbulb_is_enabled then require("konrad.lsp.lightbulb").hide() end
        print("Setting Code Action LightBulb to: " .. tostring(lightbulb_is_enabled))
    end, {
        desc = "Enable/disable lightbulb codeaction indicator",
    })

    vim.api.nvim_create_autocmd("CursorHold", {
        group = augroup,
        buffer = bufnr,
        callback = function()
            if not lightbulb_is_enabled then return end
            vim.schedule(function() require("konrad.lsp.lightbulb").show(bufnr, 0) end)
        end,
        desc = "Show lightbulb",
    })

    vim.api.nvim_create_autocmd("CursorMoved", {
        group = augroup,
        buffer = bufnr,
        callback = function()
            if not lightbulb_is_enabled then return end
            vim.schedule(require("konrad.lsp.lightbulb").hide)
        end,
        desc = "Hide lightbulb",
    })

    return {
        commands = { "LightBulbToggle" },
    }
end

M.detach = function() require("konrad.lsp.lightbulb").hide() end

return M
