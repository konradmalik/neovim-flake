---@param winid integer
local function scroll_to_bottom(winid)
    local last_line = vim.fn.line("$", winid)
    vim.api.nvim_win_set_cursor(winid, { last_line, 0 })
end

---tries to find among current windows
---@param bufnr integer
---@return integer?
local function get_or_create_window(bufnr)
    local winnr
    local potential_wins = vim.fn.win_findbuf(bufnr) or {}
    if #potential_wins == 0 then
        winnr = vim.api.nvim_open_win(bufnr, false, {
            win = 0,
            split = "right",
            noautocmd = true,
        })
    elseif #potential_wins == 1 then
        winnr = potential_wins[1]
    else
        vim.notify(
            "found runner_bufnr in multiple windows, shouldn't be possible",
            vim.log.levels.ERROR
        )
        return nil
    end
    return winnr
end

---just one global buffer
local runner_bufnr
local function get_or_create_buffer()
    if not runner_bufnr or not vim.api.nvim_buf_is_valid(runner_bufnr) then
        runner_bufnr = vim.api.nvim_create_buf(false, true)
    end
end

-- sometimes data comes in the form of {""} or {123,""}
-- which adds extraneous new lines when setting buf lines
---@param data string[] data; changed in-place
local function filter_out_trailing_empty_string(data)
    local count = #data
    local last = data[count]
    if last == "" then table.remove(data, count) end
end

---@class RunOpts
---@field bufnr integer? buffer to save the output it. If not provided, will use a dedicated runner's buffer.
---@field cwd string? working directory. Current if nil.

---Runs a given command and saves it's output in the provided buffer.
---The buffer contents will be entirely replaced.
---@param cmd string|string[] if string, runs in a shell, else runs without shell
---@param opts RunOpts optional configuration
local function run(cmd, opts)
    local bufnr = opts.bufnr
    local cwd = opts.cwd

    if not bufnr then
        get_or_create_buffer()
        bufnr = runner_bufnr
    elseif bufnr and not vim.api.nvim_buf_is_valid(bufnr) then
        vim.notify("invalid bufnr: " .. bufnr, vim.log.levels.ERROR)
    end
    get_or_create_window(bufnr)

    local cmd_str
    if type(cmd) == "table" then
        cmd_str = table.concat(cmd, " ")
    else
        cmd_str = cmd
    end

    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
        "Command: '" .. cmd_str .. "'",
        "Working dir: '" .. vim.loop.cwd() .. "'",
        "",
    })

    ---@param data string[]
    ---@param event "stdout"|"stderr"|"exit"
    local on_event = function(_, data, event)
        if event == "exit" then
            vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, { "Exit code: " .. data })
            local winid = get_or_create_window(bufnr)
            if winid then scroll_to_bottom(winid) end
            return
        end

        if data then
            filter_out_trailing_empty_string(data)
            vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, data)
            local winid = get_or_create_window(bufnr)
            if winid then scroll_to_bottom(winid) end
        end
    end

    vim.fn.jobstart(cmd, {
        cwd = cwd,
        on_stdout = on_event,
        on_stderr = on_event,
        on_exit = on_event,
        stdout_buffered = false,
        stderr_buffered = false,
    })
end

local M = {}

M.run = run

return M
