-- Local plugin checkouts to load in nvim-dev instead of the packaged plugins,
-- keyed by the packaged dir name (pack/*/start/<name> in the nix store).
---@type table<string, string>
local checkouts = {
    -- ["nvim-lspconfig"] = "~/Code/github.com/konradmalik/nvim-lspconfig",
}

-- dev mode only, it has no nix build
if vim.g.nix_build_id or vim.tbl_isempty(checkouts) then return end

---@type string[]
local dirs = vim.tbl_map(vim.fs.normalize, vim.tbl_values(checkouts))

-- A prepended checkout would only shadow the packaged copy (e.g. vim.lsp.config merges both),
-- and one start package can't be dropped from 'packpath'. So drop the whole roots and put their
-- start packages on 'rtp' ourselves, minus the replaced ones.
---@type string[]
local packpath = {}
for _, root in ipairs(vim.split(vim.o.packpath, ",")) do
    ---@type string[]
    local found = vim.fn.globpath(root, "pack/*/start/*", false, true)
    if #found == 0 then table.insert(packpath, root) end
    for _, dir in ipairs(found) do
        if not checkouts[vim.fs.basename(dir)] then table.insert(dirs, dir) end
    end
end
vim.o.packpath = table.concat(packpath, ",")

-- plugins before the user config so it can override them, their after/ dirs at the end
vim.opt.rtp:prepend(table.concat(dirs, ","))
vim.opt.rtp:append(table.concat(dirs, "/after,") .. "/after")
