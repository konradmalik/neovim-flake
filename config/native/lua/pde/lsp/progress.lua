-- highlight group for progress window
local highlight = "Normal:NonText"
-- how long to keep done message for until closing
local keep_done_message_ms = 2000
local timer = assert(vim.uv.new_timer(), "cannot create timer")

-- Buffer number and window id for the floating window
---@type integer? bufnr of the progress window
local float_bufnr
---@type integer? winid of the progress window
local float_winid
---@type string? last received message. If progress message is nil, then the last one is still valid
local last_message

---@alias LspProgress lsp.WorkDoneProgressBegin|lsp.WorkDoneProgressReport|lsp.WorkDoneProgressEnd

---Get the progress message for all clients
---@param progress LspProgress
---@return string?
local function get_lsp_progress_msg(progress)
    local message = progress.message or last_message
    last_message = message

    if progress.title and message then
        message = progress.title .. ": " .. message
    elseif progress.title then
        message = progress.title
    end

    if progress.percentage and message then
        message = "[" .. progress.percentage .. "%] " .. message
    end

    return message
end

---@param progress LspProgress
---@return boolean
local function check_is_done(progress) return progress.kind == "end" end

---@param winid integer
---@return boolean
local function is_win_valid(winid)
    return vim.api.nvim_win_is_valid(winid)
        and vim.api.nvim_win_get_tabpage(winid) == vim.api.nvim_get_current_tabpage()
end

---@param message string
---@param win_row integer
local function create_floating_win(message, win_row)
    float_bufnr = vim.api.nvim_create_buf(false, true)
    float_winid = vim.api.nvim_open_win(float_bufnr, false, {
        relative = "editor",
        width = #message,
        height = 1,
        row = win_row,
        col = vim.o.columns - #message,
        style = "minimal",
        noautocmd = true,
        border = vim.g.border_style,
    })
    vim.api.nvim_set_option_value("winfixbuf", true, { win = float_winid })
end

---@param winid integer
---@param message string
---@param win_row integer
local function update_floating_win(winid, message, win_row)
    vim.api.nvim_win_set_config(winid, {
        relative = "editor",
        width = #message,
        row = win_row,
        col = vim.o.columns - #message,
    })
end

local function cleanup_floating_win()
    if float_winid and vim.api.nvim_win_is_valid(float_winid) then
        vim.api.nvim_win_close(float_winid, true)
    end
    if float_bufnr and vim.api.nvim_buf_is_valid(float_bufnr) then
        vim.api.nvim_buf_delete(float_bufnr, { force = true })
    end
    float_winid = nil
end

vim.api.nvim_create_autocmd({ "LspProgress" }, {
    callback = function(ev)
        ---@type LspProgress
        local progress = ev.data.params.value
        local message = get_lsp_progress_msg(progress)
        if not message or #message == 0 then return end

        -- The row position of the floating window. Just right above the status line.
        local win_row = vim.o.lines - vim.o.cmdheight - 4
        if not float_winid or not is_win_valid(float_winid) then
            create_floating_win(message, win_row)
        else
            update_floating_win(float_winid, message, win_row)
        end
        vim.wo[float_winid].winhl = highlight
        if float_bufnr ~= nil then
            vim.api.nvim_buf_set_lines(float_bufnr, 0, 1, false, { message })
        else
            vim.notify("progress: float_bufnr was nil", vim.log.levels.ERROR)
        end

        local isDone = check_is_done(progress)
        if not isDone then
            timer:stop()
        else
            -- schedule to keep the done message for a while
            timer:start(keep_done_message_ms, 0, vim.schedule_wrap(cleanup_floating_win))
        end
    end,
})
