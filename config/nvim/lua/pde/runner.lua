---@param winid integer
local function scroll_to_bottom(winid)
    local last_line = vim.fn.line("$", winid)
    vim.api.nvim_win_set_cursor(winid, { last_line, 0 })
end

local function is_active_win(winid) return vim.api.nvim_get_current_win() == winid end

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

---@type integer? just one global buffer
local runner_bufnr
---@return integer
local function get_or_create_buffer()
    if not runner_bufnr or not vim.api.nvim_buf_is_valid(runner_bufnr) then
        runner_bufnr = vim.api.nvim_create_buf(false, true)
        if runner_bufnr == 0 then
            vim.notify("cannot create runner buffer", vim.log.levels.ERROR)
            runner_bufnr = -1
        end
        vim.bo[runner_bufnr].syntax = "markdown"
        vim.treesitter.start(runner_bufnr, "markdown")
        return runner_bufnr
    end

    return runner_bufnr
end

---@class RunOpts
---@field bufnr integer? buffer to save the output it. If not provided, will use a dedicated runner's buffer.
---@field cwd string? working directory. Current if nil.

---@type vim.SystemObj?
local system_object

---Runs a given command and saves it's output in the provided buffer.
---The buffer contents will be entirely replaced.
---@param cmd string|string[] if string, runs in a shell, else runs without shell
---@param opts RunOpts optional configuration
local function run(cmd, opts)
    local bufnr = opts.bufnr
    local cwd = opts.cwd

    if system_object then
        if not system_object:is_closing() then system_object:kill(9) end
        system_object:wait()
        system_object = nil
    end

    if not bufnr then
        bufnr = get_or_create_buffer()
    elseif bufnr and not vim.api.nvim_buf_is_valid(bufnr) then
        vim.notify("invalid bufnr: " .. bufnr, vim.log.levels.ERROR)
    end
    get_or_create_window(bufnr)

    if type(cmd) == "string" then cmd = { cmd } end
    local cmd_str = table.concat(cmd, " ")

    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
        "Command:",
        "```bash",
        cmd_str,
        "```",
        "",
        "Working dir:",
        "```bash",
        cwd,
        "```",
        "",
    })

    ---@param data string
    local on_data = function(_, data)
        if data then
            data = data:gsub("\n+", "")
            vim.schedule(function()
                vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, { data })
                local winid = get_or_create_window(bufnr)
                if winid and not is_active_win(winid) then scroll_to_bottom(winid) end
            end)
        end
    end

    ---@param data vim.SystemCompleted
    local on_exit = function(data)
        vim.schedule(function()
            vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, { "Exit code: " .. data.code })
            local winid = get_or_create_window(bufnr)
            if winid and not is_active_win(winid) then scroll_to_bottom(winid) end
        end)
        system_object = nil
    end

    system_object = vim.system(cmd, {
        cwd = cwd,
        text = true,
        stdout = on_data,
        stderr = on_data,
    }, on_exit)
end

vim.api.nvim_create_user_command("RunnerShowBuffer", function()
    if not runner_bufnr then
        vim.notify("runner_bufnr does not exist yet", vim.log.levels.INFO)
        return
    end

    local winid = get_or_create_window(runner_bufnr)
    if not winid then return end

    vim.api.nvim_set_current_win(winid)
end, {
    desc = "Loads runner output buffer in the current window if not loaded anywhere and if buffer exists",
})

return {
    run = run,
}
