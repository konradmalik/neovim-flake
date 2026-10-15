-- format on save: conform, then LSP, then formatprg/formatexpr
vim.g.autoformat_enabled = true

local timeout_ms = 2000
local conform = require("conform")
-- no format_on_save, formatting is driven by the autocmd below
conform.setup({
    formatters_by_ft = {
        json = { "prettier" },
        jsonc = { "prettier" },
        lua = { "stylua" },
        markdown = { "prettier" },
        toml = { "taplo" },
        yaml = { "prettier" },
    },
})

---@param bufnr integer
---@param join_undo boolean
local function trim_trailing_blank_lines(bufnr, join_undo)
    local last = vim.api.nvim_buf_line_count(bufnr)
    local cutoff = last
    while cutoff > 0 do
        local line = vim.api.nvim_buf_get_lines(bufnr, cutoff - 1, cutoff, false)[1]
        if line ~= "" then break end
        cutoff = cutoff - 1
    end
    if cutoff >= last then return end

    if join_undo then pcall(vim.cmd.undojoin) end
    vim.api.nvim_buf_set_lines(bufnr, cutoff, last, false, {})
end

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

    local formatters = conform.list_formatters_for_buffer(bufnr)
    local clients = vim.lsp.get_clients({
        bufnr = bufnr,
        method = vim.lsp.protocol.Methods.textDocument_formatting,
    })

    -- conform if it has formatters configured for this buffer
    if #formatters > 0 then
        -- passed explicitly so conform warns about missing binaries instead of skipping them silently
        conform.format({ bufnr = bufnr, formatters = formatters, lsp_format = "never", timeout_ms = timeout_ms })
        trim_trailing_blank_lines(bufnr, true)
    -- then LSP if available
    elseif #clients > 0 then
        vim.lsp.buf.format({ bufnr = bufnr, timeout_ms = timeout_ms })
        trim_trailing_blank_lines(bufnr, true)
    -- fallback: use formatexpr/formatprg via gq
    elseif vim.bo[bufnr].formatprg ~= "" or vim.bo[bufnr].formatexpr ~= "" then
        local view = vim.fn.winsaveview()
        vim.cmd("silent keepjumps normal! gggqG")
        vim.fn.winrestview(view)
        trim_trailing_blank_lines(bufnr, true)
    else
        trim_trailing_blank_lines(bufnr, false)
    end
end

vim.api.nvim_create_user_command("AutoFormatToggle", function()
    vim.g.autoformat_enabled = not vim.g.autoformat_enabled
    vim.notify("Setting autoformatting to: " .. tostring(vim.g.autoformat_enabled), vim.log.levels.INFO)
end, {
    desc = "Enable/disable autoformat globally",
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
