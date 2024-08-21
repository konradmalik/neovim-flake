local state_name = "pde-state.json"
---@type table?
local cached_state

---@return string
local function get_file_path()
    local data = vim.fn.stdpath("data")
    return data .. "/" .. state_name
end

---@param state table
---@return boolean
local function save(state)
    local path = get_file_path()
    local json = vim.json.encode(state)
    local ok = vim.fn.writefile({ json }, path) == 0
    if ok then cached_state = state end
    return ok
end

---@return table?
local function load_or_cached()
    if cached_state then return cached_state end

    local path = get_file_path()
    local ok, lines = pcall(vim.fn.readfile, path)
    if not ok or #lines ~= 1 then return nil end

    local state = vim.json.decode(lines[1])
    cached_state = state
    return cached_state
end

local M = {}

---set and persist value
---@param name string
---@param value any
---@return boolean
function M.set(name, value)
    local state = load_or_cached() or {}
    state[name] = value
    return save(state)
end

---get value
---@param name string
---@return table?
function M.get(name)
    local state = load_or_cached() or {}
    return state[name]
end

---clear (remove) persisted state
---@return boolean
function M.clear()
    local path = get_file_path()
    if vim.fn.delete(path) ~= 0 then return false end

    cached_state = {}
    return true
end

return M
