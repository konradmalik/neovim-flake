local M = {}

---Get PATH executable, returns nil if not found
---@param binary string
---@return string | nil
M.path_executable = function(binary)
    local exe = vim.fn.exepath(binary)
    if exe == "" then return nil end
    return exe
end

---Returns a full path to exec from PATH if found,
---if not found, then returns the provided one
---@param binname string
---@param fullpath string
---@return string
M.from_path_or_default = function(binname, fullpath) return M.path_executable(binname) or fullpath end

---useful for example when deciding if to attach LSP client to that buffer
---@param bufnr integer buffer to check. 0 for current
---@return boolean true if the buffer represents a real, readable file
M.is_buf_readable_file = function(bufnr)
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    return vim.fn.filereadable(bufname) == 1
end

---Finds a file or directory
---@param names string[]|string will be matched against with :match(name)
---@param opts table? type='file', 'directory' and more
---@return string|nil
M.find = function(names, opts)
    if type(names) == "string" then names = { names } end

    local defaults = {
        upward = true,
        stop = vim.uv.os_homedir(),
        path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
    }

    opts = vim.tbl_deep_extend("force", defaults, opts or {})

    local found = vim.fs.find(function(name, _)
        for _, pattern in ipairs(names) do
            if name:match(pattern) then return true end
        end
        return false
    end, opts)
    if #found == 0 then return nil end
    return found[1]
end

return M
