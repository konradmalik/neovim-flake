-- we have conform at home.
-- conform at home:
vim.g.autoformat_enabled = true

---@param bufnr integer?
local function format(bufnr)
    bufnr = bufnr or 0

    if vim.bo[bufnr].buftype ~= "" then
        -- skip formatting for special buffers
        return
    end

    local ft = vim.bo[bufnr].filetype
    if ft:find("^git.*") then
        -- skip formatting for special filetypes
        return
    end

    local clients = vim.lsp.get_clients({
        bufnr = bufnr,
        method = vim.lsp.protocol.Methods.textDocument_formatting,
    })

    -- LSP if available
    if #clients > 0 then
        vim.lsp.buf.format({ bufnr = bufnr, timeout_ms = 2000 })
    -- fallback: use formatexpr/formatprg via gq
    elseif vim.bo[bufnr].formatprg ~= "" or vim.bo[bufnr].formatexpr ~= "" then
        local view = vim.fn.winsaveview()
        vim.cmd("silent keepjumps normal! gggqG")
        vim.fn.winrestview(view)
    end
end

vim.api.nvim_create_user_command("AutoFormatToggle", function()
    vim.g.autoformat_enabled = not vim.g.autoformat_enabled
    vim.notify(
        "Setting autoformatting to: " .. tostring(vim.g.autoformat_enabled),
        vim.log.levels.INFO
    )
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
