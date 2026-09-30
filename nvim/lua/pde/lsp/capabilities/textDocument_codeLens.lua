local keymapper = require("pde.lsp.keymapper")

vim.g.codelens_enabled = true

vim.api.nvim_create_user_command("CodeLensToggle", function()
    vim.g.codelens_enabled = not vim.g.codelens_enabled
    vim.lsp.codelens.enable(vim.g.codelens_enabled)
    vim.notify("Setting codelens to: " .. tostring(vim.g.codelens_enabled), vim.log.levels.INFO)
end, {
    desc = "Enable/disable codelens with lsp",
})

---@type pde.lsp.Feature
return {
    attach = function(_, bufnr)
        vim.lsp.codelens.enable(vim.g.codelens_enabled, { bufnr = bufnr })
        keymapper.set(bufnr, "grl", vim.lsp.codelens.run, "CodeLens run")
    end,

    detach = function(_, bufnr)
        vim.lsp.codelens.enable(false, { bufnr = bufnr })
        keymapper.del(bufnr, "grl")
    end,
}
