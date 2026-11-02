local method = "textDocument/foldingRange"
local foldexpr = "v:lua.vim.lsp.foldexpr()"
local imports_enabled = false

---@param win integer
local function use_lsp(win)
    vim.wo[win][0].foldmethod = "expr"
    vim.wo[win][0].foldexpr = foldexpr
    vim.wo[win][0].foldtext = "v:lua.vim.lsp.foldtext()"
end

-- back to the global values from folds.lua; anything not set by use_lsp (a modeline, say) stays
---@param win integer
local function use_default(win)
    if vim.wo[win][0].foldexpr ~= foldexpr then return end
    vim.wo[win][0].foldmethod = vim.go.foldmethod
    vim.wo[win][0].foldexpr = vim.go.foldexpr
    vim.wo[win][0].foldtext = vim.go.foldtext
end

---@param win integer
---@param bufnr integer
local function close_imports(win, bufnr)
    -- foldclose needs the folding provider, which lsp foldexpr creates (scheduled) on first use.
    -- didOpen is sent before LspAttach, so waiting for it in LspNotify never sees the first open
    vim.api.nvim_win_call(win, function() vim.lsp.foldexpr(1) end)
    vim.schedule(function()
        if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == bufnr then
            vim.lsp.foldclose("imports", win)
        end
    end)
end

-- windows opened on the buffer later, or showing it again after a detach while it was hidden
local augroup = vim.api.nvim_create_augroup("pde-lsp-folding", { clear = true })
vim.api.nvim_create_autocmd("BufWinEnter", {
    group = augroup,
    callback = function(args)
        local win = vim.api.nvim_get_current_win()
        if next(vim.lsp.get_clients({ bufnr = args.buf, method = method })) then
            use_lsp(win)
        else
            use_default(win)
        end
    end,
    desc = "Use lsp folds where a client supports them",
})

---@class pde.lsp.Folding: pde.lsp.Feature
---@field imports pde.lsp.Toggle

---@type pde.lsp.Folding
return {
    attach = function(_, bufnr)
        for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
            use_lsp(win)
            if imports_enabled then close_imports(win, bufnr) end
        end
    end,

    detach = function(_, bufnr)
        for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
            use_default(win)
        end
    end,

    imports = {
        enable = function(enable)
            imports_enabled = enable ~= false
            if not imports_enabled then return end
            -- buffers attached before enabling won't attach again, so close their imports now
            for _, win in ipairs(vim.api.nvim_list_wins()) do
                if vim.wo[win][0].foldexpr == foldexpr then close_imports(win, vim.api.nvim_win_get_buf(win)) end
            end
        end,
        is_enabled = function() return imports_enabled end,
    },
}
