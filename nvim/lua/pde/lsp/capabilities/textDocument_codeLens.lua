local codelens_is_enabled = true

---@type CapabilityHandler
return {
    attach = function(data)
        local keymapper = require("pde.lsp.keymapper")

        local bufnr = data.bufnr
        -- it's either client or buffer
        vim.lsp.codelens.enable(codelens_is_enabled, { bufnr = bufnr })

        vim.api.nvim_buf_create_user_command(bufnr, "CodeLensToggle", function()
            codelens_is_enabled = not codelens_is_enabled
            vim.lsp.codelens.enable(codelens_is_enabled)
            print("Setting codelens to: " .. tostring(codelens_is_enabled))
        end, {
            desc = "Enable/disable codelens with lsp",
        })

        local opts_with_desc = keymapper.opts_for(bufnr)
        vim.keymap.set("n", "grl", vim.lsp.codelens.run, opts_with_desc("CodeLens run"))
    end,

    detach = function(_, bufnr)
        vim.lsp.codelens.enable(false, { bufnr = bufnr })
        vim.api.nvim_buf_del_keymap(bufnr, "n", "grl")
        vim.api.nvim_buf_del_user_command(bufnr, "CodeLensToggle")
    end,
}
