local runner_winid
local runner_bufnr

local function create_buf_and_win_if_needed()
    if not runner_bufnr or not vim.api.nvim_buf_is_valid(runner_bufnr) then
        runner_bufnr = vim.api.nvim_create_buf(false, true)
    end

    if not runner_winid or not vim.api.nvim_win_is_valid(runner_winid) then
        runner_winid = vim.api.nvim_open_win(runner_bufnr, false, {
            win = 0,
            split = "right",
            noautocmd = true,
        })
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

---@class runOpts
---@field bufnr integer? buffer to save the output it. If not provided, will use a dedicated runner's buffer.
---@field cwd string? working directory. Current if nil.

---Runs a given command and saves it's output in the provided buffer.
---The buffer contents will be entirely replaced.
---@param cmd string|string[] if string, runs in a shell, else runs without shell
---@param opts runOpts optional configuration
local function run(cmd, opts)
    local bufnr = opts.bufnr
    local cwd = opts.cwd

    if not bufnr then
        create_buf_and_win_if_needed()
        bufnr = runner_bufnr
    elseif bufnr and not vim.api.nvim_buf_is_valid(bufnr) then
        vim.notify("invalid bufnr: " .. bufnr, vim.log.levels.ERROR)
    end

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
    local on_event = function(_, data)
        if data then
            filter_out_trailing_empty_string(data)
            vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, data)
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
