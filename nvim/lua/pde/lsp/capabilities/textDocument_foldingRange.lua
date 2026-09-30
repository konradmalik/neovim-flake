vim.g.foldingimports_enabled = false

vim.api.nvim_create_user_command("FoldingImportsToggle", function()
    vim.g.foldingimports_enabled = not vim.g.foldingimports_enabled
    vim.notify("Setting imports folding to: " .. tostring(vim.g.foldingimports_enabled), vim.log.levels.INFO)
end, {
    desc = "Enable/disable folding imports with lsp",
})

-- one autocmd per buffer, not per client, so a second supporting client doesn't add another
local augroup = vim.api.nvim_create_augroup("pde-lsp-folding", { clear = true })

---@class pde.lsp.FoldOptions
---@field foldmethod string
---@field foldexpr string|function
---@field foldtext string|function

---@type table<integer, pde.lsp.FoldOptions>
local originals_per_win = {}

---@type pde.lsp.Feature
return {
    attach = function(_, bufnr)
        local win = vim.fn.bufwinid(bufnr)
        -- don't overwrite: a second supporting client would record the lsp values as the originals
        if vim.api.nvim_win_is_valid(win) and not originals_per_win[win] then
            originals_per_win[win] = {
                foldmethod = vim.wo[win][0].foldmethod,
                foldexpr = vim.wo[win][0].foldexpr,
                foldtext = vim.wo[win][0].foldtext,
            }
            -- NOTE this change first removes the foldcolumn
            -- then adds it only after lsp responds with folds
            -- which causes the current line to update, but the rest not
            -- this has a weird effect of text moving right as we go down
            -- a workaround is to force foldcolumn to some constant number, done in folds.lua
            vim.wo[win][0].foldmethod = "expr"
            vim.wo[win][0].foldexpr = vim.lsp.foldexpr
            vim.wo[win][0].foldtext = vim.lsp.foldtext
        end

        vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
        vim.api.nvim_create_autocmd("LspNotify", {
            desc = "Folding imports",
            group = augroup,
            buffer = bufnr,
            callback = function(args)
                if
                    vim.g.foldingimports_enabled
                    and args.data.method == vim.lsp.protocol.Methods.textDocument_didOpen
                then
                    local auwin = vim.fn.bufwinid(args.buf)
                    if vim.api.nvim_win_is_valid(auwin) then vim.lsp.foldclose("imports", auwin) end
                end
            end,
        })
    end,

    detach = function(_, bufnr)
        vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
        local win = vim.fn.bufwinid(bufnr)
        -- attach only records originals when the buffer was displayed, and the
        -- window may be gone or be a different one by now
        local originals = originals_per_win[win]
        if not originals or not vim.api.nvim_win_is_valid(win) then return end
        originals_per_win[win] = nil
        vim.wo[win][0].foldmethod = originals.foldmethod
        vim.wo[win][0].foldexpr = originals.foldexpr
        vim.wo[win][0].foldtext = originals.foldtext
    end,
}
