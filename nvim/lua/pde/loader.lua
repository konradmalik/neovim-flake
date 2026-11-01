---Compare the build baked in by nix with the one seen on the previous start and record the current one.
---@return boolean
local function check_build_changed()
    local id = vim.g.nix_build_id
    -- dev mode loads the config live, there is no build to track
    if not id then return false end

    local stamp = vim.fs.joinpath(vim.fn.stdpath("state"), "build-id")
    if vim.fn.filereadable(stamp) == 1 and vim.fn.readfile(stamp)[1] == id then return false end

    vim.fn.mkdir(vim.fs.dirname(stamp), "p")
    vim.fn.writefile({ id }, stamp)
    return true
end

---@class pde.loader
local M = {}

---True on the first start after a nix rebuild. Caches are reset already, modules can use it to
---regenerate their own artifacts before they are used.
M.build_changed = check_build_changed()

-- Bytecode is keyed by file path and nix store paths change with every build, so entries of old
-- builds are never hit again and nvim never prunes them. Drop them all, before enable() recreates
-- the dir (cache writes assume it exists).
if M.build_changed then
    vim.fn.delete(vim.loader.path, "rf")
    vim.schedule(function() vim.notify("New build detected, caches reset", vim.log.levels.INFO) end)
end

vim.loader.enable()

return M
