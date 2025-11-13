-- https://github.com/liangxianzhe/floating-input.nvim

---@param winid integer
---@param input_width integer
---@return table
local function window_center(winid, input_width)
    return {
        relative = "win",
        row = vim.api.nvim_win_get_height(winid) / 2 - 1,
        col = vim.api.nvim_win_get_width(winid) / 2 - input_width / 2,
    }
end

local under_cursor = {
    relative = "cursor",
    row = 1,
    col = 0,
}

local M = {}

function M.input(opts, on_confirm, win_config)
    local prompt = opts.prompt or "Input: "
    local default = opts.default or ""
    on_confirm = on_confirm or function() end

    -- Calculate a minimal width with a padding
    local default_length = vim.str_utfindex(default, "utf-8")
    local default_width = default_length + 10
    local prompt_width = vim.str_utfindex(prompt, "utf-8") + 10
    local input_width = default_width > prompt_width and default_width or prompt_width

    local default_win_config = {
        focusable = true,
        style = "minimal",
        width = input_width,
        height = 1,
        title = prompt,
    }

    -- Apply user's window config.
    win_config = vim.tbl_deep_extend("force", default_win_config, win_config)

    -- Place the window near cursor or at the center of the window.
    if prompt == "New Name: " then
        win_config = vim.tbl_deep_extend("force", win_config, under_cursor)
    else
        win_config = vim.tbl_deep_extend("force", win_config, window_center(0, win_config.width))
    end

    -- Create floating window.
    local buffer = vim.api.nvim_create_buf(false, true)
    local window = vim.api.nvim_open_win(buffer, true, win_config)

    -- avoid hiding text
    vim.wo[window].wrap = false
    vim.wo[window].sidescrolloff = 5

    vim.api.nvim_buf_set_text(buffer, 0, 0, 0, 0, { default })

    -- Put cursor at the end of the default value
    vim.cmd("startinsert")
    vim.api.nvim_win_set_cursor(window, { 1, default_length + 1 })

    -- Enter to confirm
    vim.keymap.set({ "n", "i", "v" }, "<cr>", function()
        local lines = vim.api.nvim_buf_get_lines(buffer, 0, 1, false)
        vim.cmd("stopinsert")
        vim.api.nvim_win_close(window, true)
        on_confirm(lines[1])
    end, { buffer = buffer })

    -- Esc or q to close
    vim.keymap.set("n", "<esc>", function()
        vim.cmd("stopinsert")
        vim.api.nvim_win_close(window, true)
        on_confirm(nil)
    end, { buffer = buffer })
    vim.keymap.set("n", "q", function()
        vim.cmd("stopinsert")
        vim.api.nvim_win_close(window, true)
        on_confirm(nil)
    end, { buffer = buffer })
end

return M
