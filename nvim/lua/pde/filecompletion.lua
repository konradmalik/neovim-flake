---Makes built-in file completion (i_CTRL-X_CTRL-F) complete relative to the current
---file instead of the effective cwd, which is usually the project root.
---
---'path' is not used by i_CTRL-X_CTRL-F and 'autochdir' is global, so the effective
---cwd is the only knob. Swap in a buffer-local one (:bcd) for the duration of insert
---mode, which leaves :make/:grep/:terminal and any project-dir bcd alone.
---See :h i_CTRL-X_CTRL-F, :h current-directory and :h project-dir.
local M = {}

local group = vim.api.nvim_create_augroup("pde-file-completion", { clear = true })

---Buffers whose own directory is currently swapped in.
---@type table<integer, true>
local swapped = {}

---Set the buffer-local directory, or unset it again when dir is nil.
---@param dir string?
local function set_bcd(dir)
    -- :bcd takes a command-line argument, so % and # in the path need escaping
    if dir then
        vim.cmd.bcd(vim.fn.fnameescape(dir))
    else
        vim.cmd("silent! bcd!")
    end
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
---insert mode ends. A no-op when already swapped, so that re-triggering completion
---to descend a directory level keeps the same swap.
---@param buf integer
---@return boolean swapped whether a swap is now in place
function M.use_buffer_dir(buf)
    if swapped[buf] then return true end

    local dir = buffer_dir(buf)
    if not dir then return false end

    local prev = vim.fn.haslocaldir(-1, -1, buf) == 1 and vim.fn.getcwd(-1, -1, buf) or nil
    swapped[buf] = true
    set_bcd(dir)

    -- Deliberately not CompleteDone: with 'autocomplete' a popup is usually already
    -- open and CTRL-X closes it, firing CompleteDone *before* this completion runs,
    -- and descending a level fires another one mid-flight. Both would restore too
    -- early and complete from the old cwd. CmdlineEnter covers i_CTRL-O.
    vim.api.nvim_create_autocmd({ "InsertLeave", "CmdlineEnter" }, {
        group = group,
        buffer = buf,
        once = true,
        callback = function()
            swapped[buf] = nil
            if not vim.api.nvim_buf_is_valid(buf) then return end
            vim.api.nvim_buf_call(buf, function() set_bcd(prev) end)
        end,
    })

    return true
end

M._internal = {
    buffer_dir = buffer_dir,
}

return M
