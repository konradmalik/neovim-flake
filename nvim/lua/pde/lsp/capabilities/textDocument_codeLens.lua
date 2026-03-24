vim.g.codelens_enabled = true

---@type CapabilityHandler
return {
    attach = function(data)
        local keymapper = require("pde.lsp.keymapper")

        local bufnr = data.bufnr
        vim.api.nvim_buf_create_user_command(bufnr, "CodeLensToggle", function()
            vim.g.codelens_enabled = not vim.g.codelens_enabled
            vim.lsp.codelens.enable(vim.g.codelens_enabled)
            print("Setting codelens to: " .. tostring(vim.g.codelens_enabled))
        end, {
            desc = "Enable/disable codelens with lsp",
        })

        vim.lsp.codelens.enable(vim.g.codelens_enabled, { bufnr = bufnr })

        local opts_with_desc = keymapper.opts_for(bufnr)
        vim.keymap.set("n", "grl", vim.lsp.codelens.run, opts_with_desc("CodeLens run"))
    end,

    detach = function(_, bufnr)
        vim.lsp.codelens.enable(false, { bufnr = bufnr })
        vim.api.nvim_buf_del_keymap(bufnr, "n", "grl")
        vim.api.nvim_buf_del_user_command(bufnr, "CodeLensToggle")
    end,
}
