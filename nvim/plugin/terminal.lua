--- wraps message with tmux prefix so that the underlying terminal can interpret it correctly
---@param content string
---@return string
local function wrap_tmux(content) return string.format("\27Ptmux;\27%s\27\\", content) end

--- Send an OSC 9;4 escape sequence to set the terminal's progress bar.
--- See: https://rockorager.dev/misc/osc-9-4-progress-bars/
--- NOTE: this is a workaround for tmux, see https://www.reddit.com/r/neovim/comments/1rcvliq/ghostty_lsp_progress_bar/
--- normally, nvim_echo should be enough, maybe it will be in the future.
---@param state integer 0=remove, 1=default/determinate, 2=error, 3=indeterminate, 4=pause
---@param percent integer 0-100 progress percentage (only for state 1)
local function set_terminal_progress(state, percent)
    local osc = string.format("\27]9;4;%d;%d\a", state, percent)

    -- wrap in TMUX passthrough if needed
    -- needs 'set-option -g allow-passthrough on' in tmux config
    if os.getenv("TMUX") then osc = wrap_tmux(osc) end

    vim.api.nvim_ui_send(osc)
end

---@param progress lsp.WorkDoneProgressBegin|lsp.WorkDoneProgressReport|lsp.WorkDoneProgressEnd
local function show_terminal_progress(progress)
    if progress.kind == "end" then
        set_terminal_progress(0, 0)
    elseif progress.percentage then
        set_terminal_progress(1, progress.percentage)
    else
        set_terminal_progress(3, 0)
    end
end

local group = vim.api.nvim_create_augroup("pde.progress.terminal", { clear = true })
vim.api.nvim_create_autocmd("LspProgress", {
    group = group,
    callback = function(args)
        local progress = args.data.params.value
        show_terminal_progress(progress)
    end,
})
