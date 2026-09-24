-- Make built-in file completion (i_CTRL-X_CTRL-F) complete relative to the current
-- file instead of the effective cwd (usually the project root).
--
-- 'path' is not used by i_CTRL-X_CTRL-F and 'autochdir' is global, so the only knob
-- is the effective cwd. We swap in a buffer-local one (:bcd) just for the duration of
-- the completion and restore it afterwards, which keeps :make/:grep/:terminal and any
-- project-dir bcd (see :h project-dir) untouched.

local group = vim.api.nvim_create_augroup("pde-file-completion", { clear = true })

---Buffers with a currently swapped-in directory, mapped to the bcd to restore (if any).
---@type table<integer, { dir: string? }>
local active = {}

vim.keymap.set("i", "<C-x><C-f>", function()
    local keys = vim.keycode("<C-x><C-f>")
    local buf = vim.api.nvim_get_current_buf()
    local dir = vim.fn.expand("%:p:h")
    -- already swapped (reentrant call), unnamed or special buffer: pass through untouched
    if active[buf] or dir == "" or vim.bo[buf].buftype ~= "" then
        vim.api.nvim_feedkeys(keys, "n", false)
        return
    end

    active[buf] =
        { dir = vim.fn.haslocaldir(-1, -1, buf) == 1 and vim.fn.getcwd(-1, -1, buf) or nil }
    vim.cmd.bcd(vim.fn.fnameescape(dir))

    -- InsertLeave also covers ending completion without a CompleteDone (e.g. no matches)
    vim.api.nvim_create_autocmd({ "CompleteDone", "InsertLeave" }, {
        group = group,
        buffer = buf,
        once = true,
        callback = function()
            local prev = active[buf]
            active[buf] = nil
            if not prev or not vim.api.nvim_buf_is_valid(buf) then return end
            if prev.dir then
                vim.cmd.bcd(vim.fn.fnameescape(prev.dir))
            else
                vim.cmd("silent! bcd!")
            end
        end,
    })

    vim.api.nvim_feedkeys(keys, "n", false)
end, { desc = "File name completion relative to the current file" })
