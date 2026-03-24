vim.g.autoformat_enabled = true

---@param bufnr integer?
local function format(bufnr)
    bufnr = bufnr or 0

    if vim.bo[bufnr].buftype ~= "" then
        -- skip formatting for special buffers
        return
    end

    local clients = vim.lsp.get_clients({
        bufnr = bufnr,
        method = vim.lsp.protocol.Methods.textDocument_formatting,
    })

    -- this is needed for trailing empty lines
    -- and for formatexpr so just execute this always
    local view = vim.fn.winsaveview()

    -- LSP if available
    if #clients > 0 then
        vim.lsp.buf.format({ bufnr = bufnr, timeout_ms = 2000 })
    else
        -- fallback: use formatexpr/formatprg via gq
        vim.cmd("silent keepjumps normal! gggqG")
    end
    -- remove trailing empty lines
    vim.cmd([[%s/\_s*\%$//e]])

    vim.fn.winrestview(view)
end

vim.api.nvim_create_user_command("AutoFormatToggle", function()
    vim.g.autoformat_enabled = not vim.g.autoformat_enabled
    print("Setting autoformatting to: " .. tostring(vim.g.autoformat_enabled))
end, {
    desc = "Enable/disable autoformat with formatexpr globally",
})

local group = vim.api.nvim_create_augroup("pde-autoformat", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
    desc = "AutoFormat on save",
    group = group,
    callback = function(args)
        if not vim.g.autoformat_enabled then return end

        local bufnr = args.buf
        vim.api.nvim_buf_call(bufnr, function() format(bufnr) end)
    end,
})
