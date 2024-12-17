---@type table<integer,string[]>
local originals_per_win = {}

local foldingimports_is_enabled = false

---@type CapabilityHandler
return {
    attach = function(data)
        local bufnr = data.bufnr
        local win = vim.fn.bufwinid(data.bufnr)
        if vim.api.nvim_win_is_valid(win) then
            originals_per_win[win] =
                { vim.wo[win].foldmethod, vim.wo[win].foldexpr, vim.wo[win].foldtext }
            vim.wo[win].foldmethod = "expr"
            vim.wo[win].foldexpr = "v:lua.vim.lsp.foldexpr()"
            vim.wo[win].foldtext = "v:lua.vim.lsp.foldtext()"
        end

        local client = data.client
        local augroup = data.augroup
        vim.api.nvim_create_autocmd("LspNotify", {
            desc = "Folding imports by " .. client.name,
            group = augroup,
            buffer = bufnr,
            callback = function(args)
                if foldingimports_is_enabled and args.data.method == "textDocument/didOpen" then
                    local auwin = vim.fn.bufwinid(args.buf)
                    if vim.api.nvim_win_is_valid(win) then vim.lsp.foldclose("imports", auwin) end
                end
            end,
        })

        vim.api.nvim_buf_create_user_command(bufnr, "FoldingImportsToggle", function()
            foldingimports_is_enabled = not foldingimports_is_enabled
            print("Setting imports folding to: " .. tostring(foldingimports_is_enabled))
        end, {
            desc = "Enable/disable folding imports with lsp",
        })
    end,

    detach = function(_, bufnr)
        vim.api.nvim_buf_del_user_command(bufnr, "FoldingImportsToggle")
        local win = vim.fn.bufwinid(bufnr)
        if vim.api.nvim_win_is_valid(win) then
            local originals = originals_per_win[win]
            vim.wo[win].foldmethod = originals[1]
            vim.wo[win].foldexpr = originals[2]
            vim.wo[win].foldtext = originals[3]
        end
    end,
}
