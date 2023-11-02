local M = {}

---Get PATH executable, returns nil if not found
---@param binary string
---@return string | nil
M.path_executable = function(binary)
    local exe = vim.fn.exepath(binary)
    if exe == "" then
        return nil
    end
    return exe
end

---Returns a full path to exec from PATH if found,
---if not found, then returns the provided one
---@param binname any
---@param fullpath any
---@return string
M.from_path_or_default = function(binname, fullpath)
    return M.path_executable(binname) or fullpath
end

return M
