if os.getenv("TMUX") then
    --- wraps message with tmux prefix so that the underlying terminal can interpret it correctly
    --- needs 'set-option -g allow-passthrough on' in tmux config
    --- every ESC must be doubled, else tmux ends the DCS on the payload's own ST
    ---@param content string
    ---@return string
    local function wrap_tmux(content)
        return string.format("\27Ptmux;%s\27\\", (content:gsub("\27", "\27\27")))
    end

    local original_ui_send = vim.api.nvim_ui_send

    ---@diagnostic disable-next-line: duplicate-set-field
    vim.api.nvim_ui_send =
        ---@param content string
        function(content) original_ui_send(wrap_tmux(content)) end
end
