local autocmd_group = vim.api.nvim_create_augroup("editor.treesitter", { clear = true })
local diag = require("pde.syntax-diagnostics")

vim.api.nvim_create_autocmd(
    { "FileType", "TextChanged", "InsertLeave", "LspAttach", "LspDetach" },
    {
        desc = "treesitter diagnostics",
        group = autocmd_group,
        callback = function(args)
            -- simplification, but assume that if any LSP is connected, then we have diagnostics from that source
            local diagnosticProviders = vim.lsp.get_clients({ bufnr = args.buf })
            if #diagnosticProviders > 0 then
                diag.clear(args.buf)
                return
            end

            diag.diagnose(args.buf)
        end,
    }
)
