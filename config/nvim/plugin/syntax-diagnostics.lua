local ms = vim.lsp.protocol.Methods
local autocmd_group = vim.api.nvim_create_augroup("editor.treesitter", { clear = true })

vim.api.nvim_create_autocmd({ "FileType", "TextChanged", "InsertLeave" }, {
    desc = "treesitter diagnostics",
    group = autocmd_group,
    callback = function(args)
        local diagnosticProviders =
            vim.lsp.get_clients({ bufnr = args.buf, method = ms.textDocument_publishDiagnostics })
        if #diagnosticProviders > 0 then return end

        require("pde.syntax-diagnostics").diagnose(args.buf)
    end,
})
