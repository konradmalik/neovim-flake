if os.getenv("TMUX") then
    --- wraps message with tmux prefix so that the underlying terminal can interpret it correctly
    --- needs 'set-option -g allow-passthrough on' in tmux config
    ---@param content string
    ---@return string
    local function wrap_tmux(content) return string.format("\27Ptmux;\27%s\27\\", content) end

    local original_ui_send = vim.api.nvim_ui_send

    ---@diagnostic disable-next-line: duplicate-set-field
    vim.api.nvim_ui_send =
        ---@param content string
        function(content) original_ui_send(wrap_tmux(content)) end
end
