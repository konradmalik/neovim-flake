-- based on https://github.com/liangxianzhe/floating-input.nvim

---@param winid integer
---@param input_width integer
---@return vim.api.keyset.win_config
local function window_center(winid, input_width)
    return {
        relative = "win",
        row = vim.api.nvim_win_get_height(winid) / 2 - 1,
        col = vim.api.nvim_win_get_width(winid) / 2 - input_width / 2,
    }
end

---@param input_width integer
---@return vim.api.keyset.win_config
local function editor_center(input_width)
    return {
        relative = "editor",
        row = vim.o.lines / 2 - 1,
        col = vim.o.columns / 2 - input_width / 2,
    }
end

---@type vim.api.keyset.win_config
local under_cursor = {
    relative = "cursor",
    row = 1,
    col = 0,
}

---@param prompt_length integer length of the prompt text
---@param default_length integer length of the default text
---@return integer
local function get_input_width(prompt_length, default_length)
    local padding = 10
    local desired = math.max(default_length, prompt_length) + padding
    return math.min(desired, vim.o.columns - 4)
end

---@param config vim.api.keyset.win_config
---@return integer winid window id
---@return integer bufnr buffer number
local function create_window(config)
    local bufnr = vim.api.nvim_create_buf(false, true)
    local winid = vim.api.nvim_open_win(bufnr, true, config)

    -- avoid hiding text
    vim.wo[winid][0].wrap = false
    vim.wo[winid][0].sidescrolloff = 5

    return winid, bufnr
end

---@param opts vim.ui.input.Opts
---@param default_config vim.api.keyset.win_config
---@param supplied_config? vim.api.keyset.win_config
---@return vim.api.keyset.win_config
local function resolve_config(opts, default_config, supplied_config)
    local resolved_config = vim.tbl_deep_extend("force", default_config, supplied_config or {})

    -- Place the window near cursor for small scopes, centered otherwise. Editor- and
    -- project-wide scopes aren't window-bound, so center them on the whole editor.
    local placement
    if opts.scope == "line" or opts.scope == "cursor" then
        placement = under_cursor
    elseif opts.scope == "editor" or opts.scope == "project" then
        placement = editor_center(resolved_config.width)
    else
        placement = window_center(0, resolved_config.width)
    end
    return vim.tbl_deep_extend("force", resolved_config, placement)
end

local M = {}

---@param opts? vim.ui.input.Opts
---@param on_confirm fun(input?: string)
---@param win_config? vim.api.keyset.win_config
function M.input(opts, on_confirm, win_config)
    opts = opts or {}
    local prompt = opts.prompt or "Input: "
    local default = opts.default or ""
    on_confirm = on_confirm or function() end

    local prompt_length = vim.api.nvim_strwidth(prompt)
    local default_length = vim.api.nvim_strwidth(default)
    local input_width = get_input_width(prompt_length, default_length)

    ---@type vim.api.keyset.win_config
    local default_win_config = {
        focusable = true,
        style = "minimal",
        width = input_width,
        height = 1,
        title = prompt,
    }

    local window_config = resolve_config(opts, default_win_config, win_config)
    local winid, bufnr = create_window(window_config)
    vim.api.nvim_buf_set_text(bufnr, 0, 0, 0, 0, { default })
    vim.cmd("startinsert")
    vim.api.nvim_win_set_cursor(winid, { 1, #default })

    local confirmed = false
    ---@param input? string
    local close_win = function(input)
        if confirmed then return end
        confirmed = true
        if vim.api.nvim_win_is_valid(winid) then
            vim.cmd("stopinsert")
            vim.api.nvim_win_close(winid, true)
        end
        on_confirm(input)
    end

    -- Treat leaving the float (mouse, :q, window switch) as an abort so on_confirm always fires.
    vim.api.nvim_create_autocmd("BufLeave", {
        buffer = bufnr,
        once = true,
        callback = function() close_win(nil) end,
    })

    -- Enter to confirm
    vim.keymap.set({ "n", "i", "v" }, "<cr>", function()
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)
        local input = lines[1]
        close_win(input)
    end, { buffer = bufnr })

    -- Esc or q to close
    vim.keymap.set("n", "<esc>", function() close_win(nil) end, { buffer = bufnr })
    vim.keymap.set("n", "q", function() close_win(nil) end, { buffer = bufnr })
    vim.keymap.set("i", "<C-c>", function() close_win(nil) end, { buffer = bufnr })
end

return M
