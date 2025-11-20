local opts_with_desc = function(desc) return { desc = "[notes] " .. desc } end

---@class NotesConfig
---@field base_path fun(): string
---@field quicknotes string

---@type NotesConfig
local default_config = {
    base_path = function() return vim.fs.joinpath(vim.uv.os_tmpdir(), "notes") end,
    quicknotes = "notes.md",
}

---@param path string
local open_quicknotes = function(path) vim.cmd("botright vsplit + " .. path) end

---@param config NotesConfig
local set_keymaps = function(config)
    vim.keymap.set(
        "n",
        "<leader>nq",
        function() open_quicknotes(vim.fs.joinpath(config.base_path(), config.quicknotes)) end,
        opts_with_desc("Open quick-notes file")
    )
end

local M = {}

---@param config table
M.setup = function(config)
    config = vim.tbl_deep_extend("force", default_config, config)

    set_keymaps(config)
end

return M
