local bulb_bufnr = nil
local icon = ""

-- alternative to floating icon
-- vim.fn.sign_define("bulb", { text = icon })
-- vim.fn.sign_place(5, "", "bulb", vim.api.nvim_get_current_buf(), { lnum = 6, priority = 100000000000000000 })

--- Get diagnostics (LSP Diagnostic) at the cursor
---
--- Grab the code from https://github.com/neovim/neovim/issues/21985
---
--- TODO:
--- This PR (https://github.com/neovim/neovim/pull/22883) extends
--- vim.diagnostic.get to return diagnostics at cursor directly and even with
--- LSP Diagnostic structure. If it gets merged, simplify this funciton (the
--- code for filter and build can be removed).
---@param bufnr integer
---@param winnr integer
---@return table A table of LSP Diagnostic
local function get_diagnostic_at_cursor(bufnr, winnr)
    local line, col = unpack(vim.api.nvim_win_get_cursor(winnr)) -- line is 1-based indexing
    -- Get a table of diagnostics at the current line. The structure of the
    -- diagnostic item is defined by nvim (see :h diagnostic-structure) to
    -- describe the information of a diagnostic.
    local diagnostics = vim.diagnostic.get(bufnr, { lnum = line - 1 }) -- lnum is 0-based indexing
    -- Filter out the diagnostics at the cursor position. And then use each to
    -- build a LSP Diagnostic (see
    -- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#diagnostic)
    local lsp_diagnostics = {}
    for _, diag in pairs(diagnostics) do
        if diag.col <= col and diag.end_col >= col then
            table.insert(lsp_diagnostics, {
                range = {
                    ["start"] = {
                        line = diag.lnum,
                        character = diag.col,
                    },
                    ["end"] = {
                        line = diag.end_lnum,
                        character = diag.end_col,
                    },
                },
                severity = diag.severity,
                code = diag.code,
                source = diag.source or nil,
                message = diag.message,
            })
        end
    end
    return lsp_diagnostics
end

local M = {}

function M.hide()
    if not bulb_bufnr then return end
    vim.cmd(("noautocmd bwipeout %d"):format(bulb_bufnr))
    bulb_bufnr = nil
end

---does not check for codeAction support, assumes you call it on proper client
---@param bufnr integer
---@param winnr integer
function M.show(bufnr, winnr)
    M.hide()

    local params = vim.lsp.util.make_range_params()
    params.context = {
        diagnostics = get_diagnostic_at_cursor(bufnr, winnr),
    }

    vim.lsp.buf_request_all(bufnr, "textDocument/codeAction", params, function(results)
        local has_actions = false
        for _, result in pairs(results) do
            for _, action in pairs(result.result or {}) do
                if action then
                    has_actions = true
                    break
                end
            end
        end

        if not has_actions then return end
        bulb_bufnr = vim.api.nvim_create_buf(false, true)
        local winid = vim.api.nvim_open_win(bulb_bufnr, false, {
            relative = "cursor",
            width = 1,
            height = 1,
            row = -1,
            col = 1,
            style = "minimal",
            noautocmd = true,
        })
        vim.wo[winid].winhl = "Normal:CursorLineNr"
        vim.api.nvim_buf_set_lines(bulb_bufnr, 0, 1, false, { icon })
    end)
end

return M
