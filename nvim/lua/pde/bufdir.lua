---Swaps a buffer's own directory in as the current directory for the duration of an
---insert session, so that built-in file completion resolves relative to the current
---file rather than to the effective cwd -- usually the project root.
---
---'path' is not used by i_CTRL-X_CTRL-F and 'autochdir' is global, so the effective
---cwd is the only knob. A buffer-local one (:bcd) leaves :make/:grep/:terminal and
---any project-dir bcd alone.
---See :h i_CTRL-X_CTRL-F, :h current-directory and :h project-dir.
local M = {}

local group = vim.api.nvim_create_augroup("pde-bufdir", { clear = true })

---The swap in place for a buffer, if any: prev is the buffer-local directory to put
---back afterwards, nil when the buffer had none of its own.
---@type table<integer, { prev: string? }>
local swaps = {}

---Set a buffer's buffer-local directory, or unset it again when dir is nil.
---@param buf integer
---@param dir string?
local function set_bcd(buf, dir)
    if not vim.api.nvim_buf_is_valid(buf) then return end
    vim.api.nvim_buf_call(buf, function()
        if dir then
            -- :bcd takes a command-line argument, so % and # in the path need escaping
            vim.cmd.bcd(vim.fn.fnameescape(dir))
        else
            -- a no-op when the buffer has no directory of its own, see :h :bcd!
            vim.cmd.bcd({ bang = true })
        end
    end)
end

---The buffer's own buffer-local directory, or nil when it has none. getcwd() falls
---back to the effective cwd for a buffer without one, so haslocaldir() has to gate
---it; -1, -1 asks both about the buffer scope rather than a window or a tab.
---@param buf integer
---@return string?
local function local_dir(buf)
    return vim.fn.haslocaldir(-1, -1, buf) == 1 and vim.fn.getcwd(-1, -1, buf) or nil
end

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

---Point the buffer's current-directory at the directory of its own file, until
---insert mode ends or M.restore puts it back. A no-op when already swapped, so that
---re-triggering completion to descend a directory level keeps the same swap.
---@param buf integer
---@return boolean swapped whether a swap is now in place
function M.use(buf)
    if swaps[buf] then return true end

    local dir = buffer_dir(buf)
    if not dir then return false end

    swaps[buf] = { prev = local_dir(buf) }
    set_bcd(buf, dir)

    -- Deliberately not CompleteDone: with 'autocomplete' a popup is usually already
    -- open and CTRL-X closes it, firing CompleteDone *before* this completion runs,
    -- and descending a level fires another one mid-flight. Both would restore too
    -- early and complete from the old cwd. CmdlineEnter covers i_CTRL-O.
    vim.api.nvim_create_autocmd({ "InsertLeave", "CmdlineEnter" }, {
        group = group,
        buffer = buf,
        once = true,
        callback = function() M.restore(buf) end,
    })

    return true
end

---Put back the directory a swap replaced, so that completion resolves against the
---effective cwd again. A no-op when nothing is swapped, which makes it safe to call
---from a mapping and from the autocmd above, in either order and repeatedly.
---@param buf integer
function M.restore(buf)
    local swap = swaps[buf]
    if not swap then return end

    swaps[buf] = nil
    set_bcd(buf, swap.prev)
end

M._internal = {
    buffer_dir = buffer_dir,
}

return M
