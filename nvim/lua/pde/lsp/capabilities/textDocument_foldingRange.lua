vim.g.foldingimports_enabled = false

---@type table<integer,string[]>
local originals_per_win = {}

---@type CapabilityHandler
return {
    attach = function(data)
        local bufnr = data.bufnr
        local win = vim.fn.bufwinid(data.bufnr)
        if vim.api.nvim_win_is_valid(win) then
            originals_per_win[win] = {
                vim.wo[win][0].foldmethod,
                vim.wo[win][0].foldexpr,
                vim.wo[win][0].foldtext,
            }
            -- NOTE this change first removes the foldcolumn
            -- then adds it only after lsp responds with folds
            -- which causes the current line to update, but the rest not
            -- this has a weird effect of text moving right as we go down
            -- a workaround is to force foldcolumn to some constant number, done in folds.lua
            vim.wo[win][0].foldmethod = "expr"
            vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
            vim.wo[win][0].foldtext = "v:lua.vim.lsp.foldtext()"
        end

        local client = data.client
        local augroup = data.augroup
        vim.api.nvim_create_autocmd("LspNotify", {
            desc = "Folding imports by " .. client.name,
            group = augroup,
            buffer = bufnr,
            callback = function(args)
                if vim.g.foldingimports_enabled and args.data.method == "textDocument/didOpen" then
                    local auwin = vim.fn.bufwinid(args.buf)
                    if vim.api.nvim_win_is_valid(win) then vim.lsp.foldclose("imports", auwin) end
                end
            end,
        })

        vim.api.nvim_buf_create_user_command(bufnr, "FoldingImportsToggle", function()
            vim.g.foldingimports_enabled = not vim.g.foldingimports_enabled
            print("Setting imports folding to: " .. tostring(vim.g.foldingimports_enabled))
        end, {
            desc = "Enable/disable folding imports with lsp",
        })
    end,

    detach = function(_, bufnr)
        vim.api.nvim_buf_del_user_command(bufnr, "FoldingImportsToggle")
        local win = vim.fn.bufwinid(bufnr)
        if vim.api.nvim_win_is_valid(win) then
            local originals = originals_per_win[win]
            vim.wo[win][0].foldmethod = originals[1]
            vim.wo[win][0].foldexpr = originals[2]
            vim.wo[win][0].foldtext = originals[3]
        end
    end,
}
