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
    local default_width = default_length + padding
    local prompt_width = prompt_length + padding
    return default_width > prompt_width and default_width or prompt_width
end

---@param config vim.api.keyset.win_config
---@return integer winid window id
---@return integer bufnr buffer number
local function create_window(config)
    local bufnr = vim.api.nvim_create_buf(false, true)
    local winid = vim.api.nvim_open_win(bufnr, true, config)

    -- avoid hiding text
    vim.wo[winid].wrap = false
    vim.wo[winid].sidescrolloff = 5

    return winid, bufnr
end

---@param prompt string
---@param default vim.api.keyset.win_config
---@param supplied? vim.api.keyset.win_config
---@return vim.api.keyset.win_config
local function resolve_config(prompt, default, supplied)
    -- Apply user's window config.
    local resolved_config = vim.tbl_deep_extend("force", default, supplied)

    -- Place the window near cursor or at the center of the window.
    if prompt == "New Name: " then
        resolved_config = vim.tbl_deep_extend("force", resolved_config, under_cursor)
    else
        resolved_config =
            vim.tbl_deep_extend("force", resolved_config, window_center(0, resolved_config.width))
    end
    return resolved_config
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

    local prompt_length = vim.str_utfindex(prompt, "utf-8")
    local default_length = vim.str_utfindex(default, "utf-8")
    local input_width = get_input_width(prompt_length, default_length)

    ---@type vim.api.keyset.win_config
    local default_win_config = {
        focusable = true,
        style = "minimal",
        width = input_width,
        height = 1,
        title = prompt,
        noautocmd = true,
    }

    local window_config = resolve_config(prompt, default_win_config, win_config)
    local winid, bufnr = create_window(window_config)
    vim.api.nvim_buf_set_text(bufnr, 0, 0, 0, 0, { default })
    vim.cmd("startinsert")
    vim.api.nvim_win_set_cursor(winid, { 1, default_length + 1 })

    ---@param input? string
    local close_win = function(input)
        vim.cmd("stopinsert")
        vim.api.nvim_win_close(winid, true)
        on_confirm(input)
    end

    -- Enter to confirm
    vim.keymap.set({ "n", "i", "v" }, "<cr>", function()
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)
        local input = lines[1]
        close_win(input)
    end, { buffer = bufnr })

    -- Esc or q to close
    vim.keymap.set("n", "<esc>", function() close_win(nil) end, { buffer = bufnr })
    vim.keymap.set("n", "q", function() close_win(nil) end, { buffer = bufnr })
end

return M
