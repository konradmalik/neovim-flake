-- based on https://github.com/rockyzhang24/dotfiles/blob/master/.config/nvim/lua/rockyz/lsp/progress.lua

-- highlight group for progress window
local highlight = "Normal:NonText"
local keep_done_message_ms = 2000

local icons = {
    spinner = { "⣷", "⣯", "⣟", "⡿", "⢿", "⣻", "⣽", "⣾" },
    done = "󰄬",
}

---@alias LspProgress lsp.WorkDoneProgressBegin|lsp.WorkDoneProgressReport|lsp.WorkDoneProgressEnd

---@class ProgressClient
---@field name string name of the client
---@field is_done boolean whether the progress is finished
---@field spinner_idx integer current index of the spinner
---@field winid integer? winid of the floating window
---@field bufnr integer? bufnr of the floating window
---@field message string? the progress message that will be shown in the window
---@field pos integer the position of this window counting from bottom to top
---@field timer uv_timer_t? used to delay the closing of the window and handle window closure during textlock

---@class ProgressMessage
---@field title string
---@field message string?

--- history of messages by key, because messages may rely on previous values
--- key here is client-name + progress token
---@type table<string, ProgressMessage>
local previous_messages = {}

---client properties by client id
---@type table<integer, ProgressClient>
local clients = {}

-- the total number of current windows
local total_wins = 0

--- resets the client
---@param client ProgressClient
local function reset(client)
    client.is_done = false
    client.spinner_idx = 1
    client.winid = nil
    client.bufnr = nil
    client.message = nil
    client.pos = total_wins + 1
    if client.timer and not client.timer:is_closing() then client.timer:close() end
    client.timer = nil
end

---Get the row position of the current floating window. If it is the first one, it is placed just
---right above the statusline; if not, it is placed on top of others.
---@param pos integer
---@return integer
local function get_win_row(pos) return vim.o.lines - vim.o.cmdheight - 1 - pos * 3 end

---Update the window config
---@param client ProgressClient
local function win_update_config(client)
    vim.api.nvim_win_set_config(client.winid, {
        relative = "editor",
        width = #client.message,
        height = 1,
        row = get_win_row(client.pos),
        col = vim.o.columns - #client.message,
    })
end

--- Close the window and delete the associated buffer
---@param winid integer?
---@return boolean
local function close_window(winid)
    if winid and vim.api.nvim_win_is_valid(winid) then
        vim.api.nvim_win_close(winid, true)
        return true
    end
    return false
end

--- Close buffer
---@param bufnr integer?
---@return boolean
local function close_buffer(bufnr)
    if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
        vim.api.nvim_buf_delete(bufnr, { force = true })
        return true
    end
    return false
end

---@param previous_idx integer?
local function get_spinner_idx(previous_idx)
    previous_idx = previous_idx or 1
    return (previous_idx % #icons.spinner) + 1
end

--- Assemble the output progress message and set the flag to mark if it's completed.
--- * General: ⣾ [client_name] title: message ( 5%)
--- * Done:     [client_name] title: message
---@param client ProgressClient
---@param token string
---@param progress LspProgress
---@return string
local function create_and_cache_message(client, token, progress)
    local message_key = client.name .. "-" .. token

    local message_builder = { "[", client.name, "]" }
    local title = progress.title or vim.tbl_get(previous_messages, message_key, "title")
    if title then
        table.insert(message_builder, " ")
        table.insert(message_builder, title)
    end

    local kind = progress.kind
    if kind == "end" then
        client.is_done = true
        previous_messages[message_key] = nil

        local message = progress.message
        if message then
            table.insert(message_builder, ": ")
            table.insert(message_builder, message)
        end
        return icons.done .. " " .. table.concat(message_builder)
    end

    client.is_done = false

    local message = progress.message or vim.tbl_get(previous_messages, message_key, "message")
    if message then
        table.insert(message_builder, ": ")
        table.insert(message_builder, message)
    end

    previous_messages[message_key] = { title = title, message = message }

    local percentage = progress.percentage
    if percentage then table.insert(message_builder, string.format(" (%3d%%)", percentage)) end

    client.spinner_idx = get_spinner_idx(client.spinner_idx)
    return icons.spinner[client.spinner_idx] .. " " .. table.concat(message_builder)
end

--- Create a new window or update the existing one
---@param client ProgressClient
local function create_or_update_window(client)
    local winid = client.winid
    if
        winid == nil
        or not vim.api.nvim_win_is_valid(winid)
        -- Switch to another tab
        or vim.api.nvim_win_get_tabpage(winid) ~= vim.api.nvim_get_current_tabpage()
    then
        winid = vim.api.nvim_open_win(client.bufnr, false, {
            relative = "editor",
            width = #client.message,
            height = 1,
            row = get_win_row(client.pos),
            col = vim.o.columns - #client.message,
            focusable = false,
            style = "minimal",
            border = "none",
            noautocmd = true,
        })
        vim.wo[winid].winhl = highlight
        client.winid = winid
        total_wins = total_wins + 1
    else
        win_update_config(client)
    end
end

---Show the progress message in floating window
---@param client ProgressClient
local function show_message(client)
    create_or_update_window(client)
    vim.api.nvim_buf_set_lines(client.bufnr, 0, 1, false, { client.message })
end

-- Display the progress message
local function lsp_progress_handler(args)
    local client_id = args.data.client_id

    -- Initialize the properties
    if not clients[client_id] then
        ---@type ProgressClient
        local new_client = {
            name = vim.lsp.get_client_by_id(client_id).name,
            is_done = false,
            spinner_idx = 1,
            pos = 0,
        }
        reset(new_client)
        clients[client_id] = new_client
    end
    local cur_client = clients[client_id]

    local token = tostring(args.data.params.token)
    ---@type LspProgress
    local progress = args.data.params.value
    cur_client.message = create_and_cache_message(cur_client, token, progress)

    -- Create buffer for the floating window showing the progress message and the timer used to close
    -- the window when progress report is done.
    cur_client.bufnr = cur_client.bufnr or vim.api.nvim_create_buf(false, true)
    -- Show progress message in floating window
    show_message(cur_client)

    -- Close the window when finished and adjust the positions of other windows if they exist.
    -- Let the window stay briefly on the screen before closing it (say 2s). When closing, attempt to
    -- close at intervals (say 100ms) to handle the potential textlock. We can use uv.timer to
    -- implement it.
    --
    -- NOTE:
    -- During the waiting period, if it is set for a long duration like 3s, the same server may report
    -- another around of progress notification, and this window will continue to be used for
    -- displaying. When the period is over and an attempt is made to close the window, two possible
    -- scenarios may occur:
    -- 1. the new round of progress notification report has not yet finished, so this window
    --    should not be closed.
    -- 2. the new round of progress notification report has finished. We should avoid the window being
    --    closed twice. In the code below, timer:start() will be called again and it just resets the
    --    timer, so the window will not be closed twice.
    if cur_client.is_done then
        cur_client.timer = cur_client.timer or vim.uv.new_timer()
        cur_client.timer:start(
            keep_done_message_ms,
            100,
            vim.schedule_wrap(function()
                -- To handle the scenario 1
                if not cur_client.is_done and cur_client.winid then
                    if cur_client.timer then cur_client.timer:stop() end
                    return
                end
                -- try to close window and buffer
                close_window(cur_client.winid)
                close_buffer(cur_client.bufnr)
                -- stop the timer, adjust the positions of other windows
                -- and reset properties of the client
                if cur_client.timer then
                    cur_client.timer:stop()
                    if not cur_client.timer:is_closing() then cur_client.timer:close() end
                end
                total_wins = total_wins - 1
                -- Move all windows above this closed window down by one position
                for _, c in ipairs(clients) do
                    if c.winid and c.pos > cur_client.pos then
                        c.pos = c.pos - 1
                        win_update_config(c)
                    end
                end
                -- Reset the properties
                reset(cur_client)
            end)
        )
    end
end

local group = vim.api.nvim_create_augroup("lsp_progress", { clear = true })
vim.api.nvim_create_autocmd("LspProgress", {
    group = group,
    callback = lsp_progress_handler,
})

vim.api.nvim_create_autocmd("VimResized", {
    group = group,
    callback = function()
        for _, c in ipairs(clients) do
            win_update_config(c)
        end
    end,
})
