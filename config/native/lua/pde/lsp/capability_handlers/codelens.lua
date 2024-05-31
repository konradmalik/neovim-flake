local codelens_is_enabled = true

---@type CapabilityHandler
return {
    attach = function(data)
        local keymapper = require("pde.lsp.keymapper")

        local augroup = data.augroup
        local bufnr = data.bufnr
        local client = data.client

        vim.api.nvim_buf_create_user_command(bufnr, "CodeLensToggle", function()
            codelens_is_enabled = not codelens_is_enabled
            if not codelens_is_enabled then
                for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                    vim.lsp.codelens.clear(client.id, buf)
                end
            end
            print("Setting codelens to: " .. tostring(codelens_is_enabled))
        end, {
            desc = "Enable/disable codelens with lsp",
        })

        vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "CursorHold", "InsertLeave" }, {
            group = augroup,
            buffer = bufnr,
            callback = function()
                if not codelens_is_enabled then return end
                vim.lsp.codelens.refresh({ bufnr = bufnr })
            end,
            desc = "Refresh codelens",
        })

        local opts_with_desc = keymapper.opts_for(bufnr)

        vim.api.nvim_buf_create_user_command(
            bufnr,
            "CodeLensRefresh",
            function() vim.lsp.codelens.refresh({ bufnr = bufnr }) end,
            { desc = "Refresh codelens for the current buffer" }
        )
        vim.keymap.set("n", "grl", vim.lsp.codelens.run, opts_with_desc("CodeLens run"))

        -- refresh manually right now for a start
        if codelens_is_enabled then vim.lsp.codelens.refresh({ bufnr = bufnr }) end
    end,

    detach = function(client_id, bufnr)
        vim.lsp.codelens.clear(client_id, bufnr)
        vim.api.nvim_buf_del_keymap(bufnr, "n", "grl")
        vim.api.nvim_buf_del_user_command(bufnr, "CodeLensToggle")
        vim.api.nvim_buf_del_user_command(bufnr, "CodeLensRefresh")
    end,
}
