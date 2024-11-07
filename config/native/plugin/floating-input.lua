-- https://github.com/liangxianzhe/floating-input.nvim

local function window_center(input_width)
    return {
        relative = "win",
        row = vim.api.nvim_win_get_height(0) / 2 - 1,
        col = vim.api.nvim_win_get_width(0) / 2 - input_width / 2,
    }
end

local function under_cursor(_)
    return {
        relative = "cursor",
        row = 1,
        col = 0,
    }
end

local function input(opts, on_confirm, win_config)
    local prompt = opts.prompt or "Input: "
    local default = opts.default or ""

    -- Calculate a minimal width with a bit buffer
    local default_width = vim.str_utfindex(default, "utf-8") + 10
    local prompt_width = vim.str_utfindex(prompt, "utf-8") + 10
    local input_width = default_width > prompt_width and default_width or prompt_width

    local default_win_config = {
        focusable = true,
        style = "minimal",
        border = "rounded",
        width = input_width,
        height = 1,
        title = prompt,
    }

    -- Apply user's window config.
    win_config = vim.tbl_deep_extend("force", default_win_config, win_config)

    -- Place the window near cursor or at the center of the window.
    if prompt == "New Name: " then
        win_config = vim.tbl_deep_extend("force", win_config, under_cursor(win_config.width))
    else
        win_config = vim.tbl_deep_extend("force", win_config, window_center(win_config.width))
    end

    -- Create floating window.
    local buffer = vim.api.nvim_create_buf(false, true)
    local window = vim.api.nvim_open_win(buffer, true, win_config)
    vim.api.nvim_buf_set_text(buffer, 0, 0, 0, 0, { default })

    -- Put cursor at the end of the default value
    vim.cmd("startinsert")
    vim.api.nvim_win_set_cursor(window, { 1, vim.str_utfindex(default, "utf-8") + 1 })

    -- Enter to confirm
    vim.keymap.set({ "n", "i", "v" }, "<cr>", function()
        local lines = vim.api.nvim_buf_get_lines(buffer, 0, 1, false)
        if lines[1] ~= default and on_confirm then on_confirm(lines[1]) end
        vim.api.nvim_win_close(window, true)
        vim.cmd("stopinsert")
    end, { buffer = buffer })

    -- Esc or q to close
    vim.keymap.set(
        "n",
        "<esc>",
        function() vim.api.nvim_win_close(window, true) end,
        { buffer = buffer }
    )
    vim.keymap.set(
        "n",
        "q",
        function() vim.api.nvim_win_close(window, true) end,
        { buffer = buffer }
    )
end

---@diagnostic disable-next-line: duplicate-set-field
vim.ui.input = function(opts, on_confirm) input(opts, on_confirm, {}) end
