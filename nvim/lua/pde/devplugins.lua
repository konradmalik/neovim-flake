-- Local plugin checkouts to load in nvim-dev instead of the packaged plugins,
-- keyed by the packaged dir name (pack/*/start/<name> in the nix store).
---@type table<string, string>
local checkouts = {
    -- ["nvim-lspconfig"] = "~/Code/github.com/konradmalik/nvim-lspconfig",
}

-- dev mode only, it has no nix build
if vim.g.nix_build_id or vim.tbl_isempty(checkouts) then return end

for name, path in pairs(checkouts) do
    checkouts[name] = vim.fs.normalize(path)
    if vim.fn.isdirectory(checkouts[name]) == 0 then
        error("devplugins: no directory " .. checkouts[name] .. " for " .. name)
    end
end

-- A prepended checkout would only shadow the packaged copy (e.g. vim.lsp.config merges both),
-- and one start package can't be dropped from 'packpath'. So drop the whole roots and put their
-- start packages on 'rtp' ourselves, with checkouts in place of the packaged ones.
local unmatched = vim.deepcopy(checkouts)
---@type string[]
local dirs, packpath = {}, {}
for _, root in ipairs(vim.split(vim.o.packpath, ",")) do
    ---@type string[]
    local found = vim.fn.globpath(root, "pack/*/start/*", false, true)
    if #found == 0 then table.insert(packpath, root) end
    for _, dir in ipairs(found) do
        local name = vim.fs.basename(dir)
        table.insert(dirs, checkouts[name] or dir)
        unmatched[name] = nil
    end
end
if next(unmatched) then
    error("devplugins: no packaged plugin named " .. table.concat(vim.tbl_keys(unmatched), ", "))
end
vim.o.packpath = table.concat(packpath, ",")

-- plugins before the user config so it can override them, their after/ dirs at the end
vim.opt.rtp:prepend(table.concat(dirs, ","))
vim.opt.rtp:append(table.concat(dirs, "/after,") .. "/after")
