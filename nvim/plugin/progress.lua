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
---@field bufnr integer bufnr of the floating window
---@field text string the text that will be shown in the window
---@field history table<string,ProgressMessage> history of messages by token, because messages may rely on previous values
---@field pos integer the position of this window. 1 is the most bottom
---@field timer uv_timer_t? used to delay the closing of the window

---@class ProgressMessage
---@field title string
---@field message string?

---client properties by client id
---@type table<integer, ProgressClient>
local clients = {}

-- the total number of current windows
local total_wins = 0

--- resets the client to "empty" state
---@param client ProgressClient
local function reset(client)
    client.is_done = false
    client.spinner_idx = 1
    client.text = ""
    client.pos = total_wins + 1
end

--- creates a new client
--- @param client_id integer
--- @return ProgressClient
local function new_client(client_id)
    return {
        name = vim.lsp.get_client_by_id(client_id).name,
        bufnr = vim.api.nvim_create_buf(false, true),
        text = "",
        is_done = false,
        spinner_idx = 1,
        pos = total_wins + 1,
        history = {},
    }
end

---Get the row position of the current floating window. If it is the first one, it is placed just
---right above the statusline; if not, it is placed on top of others.
---@param pos integer
---@return integer
local function get_win_row(pos) return vim.o.lines - vim.o.cmdheight - 1 - (2 * pos) end

---Get the col position of the window
---@param text_len integer
---@return integer
local function get_win_col(text_len) return vim.o.columns - text_len end

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
local function create_and_cache_message(client, token, progress)
    local message_builder = { "[", client.name, "]" }
    local title = progress.title or vim.tbl_get(client.history, token, "title")
    if title then
        table.insert(message_builder, " ")
        table.insert(message_builder, title)
    end

    local kind = progress.kind
    if kind == "end" then
        client.is_done = true
        client.history[token] = nil

        local message = progress.message
        if message then
            table.insert(message_builder, ": ")
            table.insert(message_builder, message)
        end
        client.text = icons.done .. " " .. table.concat(message_builder)
        return
    end

    client.is_done = false

    local message = progress.message or vim.tbl_get(client.history, token, "message")
    if message then
        table.insert(message_builder, ": ")
        table.insert(message_builder, message)
    end

    client.history[token] = { title = title, message = message }

    local percentage = progress.percentage
    if percentage then table.insert(message_builder, string.format(" (%3d%%)", percentage)) end

    client.spinner_idx = get_spinner_idx(client.spinner_idx)
    client.text = icons.spinner[client.spinner_idx] .. " " .. table.concat(message_builder)
end

---Update the window location and size
---@param client ProgressClient
local function reconfigure_window(client)
    if client.winid then
        vim.api.nvim_win_set_config(client.winid, {
            relative = "editor",
            col = get_win_col(#client.text),
            row = get_win_row(client.pos),
            width = #client.text,
            height = 1,
        })
    end
end

---create new window
---@param client ProgressClient
local function create_window(client)
    assert(client.winid == nil, "window for " .. client.name .. " already exists")
    local winid = vim.api.nvim_open_win(client.bufnr, false, {
        relative = "editor",
        col = get_win_col(#client.text),
        row = get_win_row(client.pos),
        width = #client.text,
        height = 1,
        focusable = false,
        style = "minimal",
        border = "none",
        noautocmd = true,
    })
    vim.wo[winid].winhl = highlight
    client.winid = winid
    total_wins = total_wins + 1
end

--- Close the window
---@param client ProgressClient
local function close_window(client)
    if client.winid then
        if vim.api.nvim_win_is_valid(client.winid) then
            vim.api.nvim_win_close(client.winid, true)
        end
        client.winid = nil
        total_wins = total_wins - 1

        -- timer is strictly related to a window
        if client.timer then
            client.timer:stop()
            if not client.timer:is_closing() then client.timer:close() end
        end
        client.timer = nil
    end
end

--- Create a new window or update the existing one
---@param client ProgressClient
local function ensure_window(client)
    local winid = client.winid
    if
        winid ~= nil
        and vim.api.nvim_win_get_tabpage(winid) ~= vim.api.nvim_get_current_tabpage()
    then
        close_window(client)
    end

    if winid == nil then
        create_window(client)
    else
        reconfigure_window(client)
    end
end

---Show the progress message in floating window
---@param client ProgressClient
local function show_message(client)
    ensure_window(client)
    vim.api.nvim_buf_set_lines(client.bufnr, 0, 1, false, { client.text })
end

---@param client ProgressClient
local function dispose_client(client)
    close_window(client)

    -- move all windows above this one down by 1
    for _, c in pairs(clients) do
        if c.pos > client.pos then
            c.pos = c.pos - 1
            reconfigure_window(c)
        end
    end

    reset(client)
end

local group = vim.api.nvim_create_augroup("lsp_progress", { clear = true })
vim.api.nvim_create_autocmd("LspProgress", {
    group = group,
    callback = function(args)
        local client_id = args.data.client_id

        if not clients[client_id] then clients[client_id] = new_client(client_id) end
        local cur_client = clients[client_id]

        local token = tostring(args.data.params.token)
        ---@type LspProgress
        local progress = args.data.params.value
        create_and_cache_message(cur_client, token, progress)

        show_message(cur_client)

        -- progress is done, we can schedule closing the window
        if cur_client.is_done then
            if cur_client.timer then
                -- was alredy scheduled; need to cancel first
                cur_client.timer:stop()
            else
                -- setup a new one otherwise
                cur_client.timer = vim.uv.new_timer()
            end
            -- wait for keep_done_message_ms and if not stopped - will close the window
            cur_client.timer:start(
                keep_done_message_ms,
                0,
                vim.schedule_wrap(function()
                    -- new message received in the meantime, not done now
                    if not cur_client.is_done then
                        if cur_client.timer then cur_client.timer:stop() end
                        return
                    end

                    -- we have go now, no way back
                    dispose_client(cur_client)
                end)
            )
        end
    end,
})

vim.api.nvim_create_autocmd({ "VimResized", "TermLeave" }, {
    group = group,
    callback = function()
        for _, c in pairs(clients) do
            reconfigure_window(c)
        end
    end,
})
