-- highlight group for progress window
local highlight = "Normal:NonText"
-- how long to keep done message for until closing
local keep_done_message_ms = 2000
local timer = vim.loop.new_timer()
-- Buffer number and window id for the floating window
local bufnr
local winid

---Get the progress message for all clients
---@param kind string begin, report or end
---@return string
local function get_lsp_progress_msg(kind)
    local prefix = ""
    if kind == "begin" then
        prefix = "Starting: "
    elseif kind == "end" then
        prefix = "Finished: "
    end
    return prefix .. vim.lsp.status()
end

---@param kind string begin, report or end
---@return boolean
local function check_is_done(kind) return kind == "end" end

vim.api.nvim_create_autocmd({ "LspProgress" }, {
    callback = function(ev)
        local kind = ev.file
        local isDone = check_is_done(kind)
        local message = get_lsp_progress_msg(kind)
        -- The row position of the floating window. Just right above the status line.
        local win_row = vim.o.lines - vim.o.cmdheight - 4
        if
            winid == nil
            or not vim.api.nvim_win_is_valid(winid)
            or vim.api.nvim_win_get_tabpage(winid) ~= vim.api.nvim_get_current_tabpage()
        then
            bufnr = vim.api.nvim_create_buf(false, true)
            winid = vim.api.nvim_open_win(bufnr, false, {
                relative = "editor",
                width = #message,
                height = 1,
                row = win_row,
                col = vim.o.columns - #message,
                style = "minimal",
                noautocmd = true,
                border = vim.g.border_style,
            })
        else
            vim.api.nvim_win_set_config(winid, {
                relative = "editor",
                width = #message,
                row = win_row,
                col = vim.o.columns - #message,
            })
        end
        vim.wo[winid].winhl = highlight
        vim.api.nvim_buf_set_lines(bufnr, 0, 1, false, { message })
        if not isDone then
            timer:stop()
        elseif isDone then
            -- schedule to keep the done message for a while
            timer:start(keep_done_message_ms, 0, function()
                timer:stop()
                vim.schedule(function()
                    if winid and vim.api.nvim_win_is_valid(winid) then
                        vim.api.nvim_win_close(winid, true)
                    end
                    if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
                        vim.api.nvim_buf_delete(bufnr, { force = true })
                    end
                    winid = nil
                end)
            end)
        end
    end,
})
