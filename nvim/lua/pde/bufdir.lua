---Swaps the current buffer's own directory in as the current directory for the duration
---of an insert session, so that built-in file completion resolves relative to the
---current file rather than to the effective cwd -- usually the project root.
---
---'path' is not used by i_CTRL-X_CTRL-F and 'autochdir' is global, so the effective
---cwd is the only knob. A buffer-local one (:bcd) leaves :make/:grep/:terminal alone.
---This owns the buffer's :bcd: leaving insert mode always unsets it.
---See :h i_CTRL-X_CTRL-F and :h current-directory.
local M = {}

local group = vim.api.nvim_create_augroup("pde-bufdir", { clear = true })

-- the swap is transient, so DirChanged listeners must not react to it
local mods = { noautocmd = true }

---The directory to complete against, or nil when the buffer has none that makes
---sense: an unnamed or special buffer, or a new file under a directory that does
---not exist yet, which would make :bcd fail with E344.
---@param buf integer
---@return string?
local function buffer_dir(buf)
    if vim.bo[buf].buftype ~= "" then return nil end
    local name = vim.api.nvim_buf_get_name(buf)
    if name == "" then return nil end
    local dir = vim.fn.fnamemodify(name, ":p:h")
    return vim.fn.isdirectory(dir) == 1 and dir or nil
end

---Point the current buffer's current-directory at the directory of its own file, until
---insert mode ends or M.restore unsets it. Safe to repeat, e.g. when re-triggering
---completion to descend a directory level.
---@return boolean swapped whether a swap is now in place
function M.use()
    local dir = buffer_dir(vim.api.nvim_get_current_buf())
    if not dir then return false end

    -- :bcd takes a command-line argument, so % and # in the path need escaping
    vim.cmd.bcd({ vim.fn.fnameescape(dir), mods = mods })
    return true
end

---Unset the current buffer's buffer-local directory, so that completion resolves
---against the effective cwd again. This also undoes a swap that leaving insert mode
---could not: one in a buffer switched away from mid-insert.
function M.restore()
    -- a no-op when the buffer has no directory of its own, see :h :bcd!
    vim.cmd.bcd({ bang = true, mods = mods })
end

-- Any exit from Insert or Replace mode (insert mappings work in both): to Normal mode,
-- i_CTRL-O or the cmdline, but not a switch between the two. Deliberately not
-- CompleteDone: with 'autocomplete' a popup is usually already open and CTRL-X closes
-- it, firing CompleteDone *before* this completion runs, and descending a level fires
-- another one mid-flight. Both would restore too early and complete from the old cwd.
vim.api.nvim_create_autocmd("ModeChanged", {
    group = group,
    pattern = "[iR]*:[^iR]*",
    callback = function() M.restore() end,
})

M._internal = {
    buffer_dir = buffer_dir,
}

return M
