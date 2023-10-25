local opts_with_desc = function(desc)
    return { noremap = true, silent = true, desc = "[notes] " .. desc }
end

local default_config = {
    base_path = "/tmp/notes",
    names = {
        quicknotes = "notes.md",
    },
}

---@param path string
local open_quicknotes = function(path)
    vim.cmd("botright vsplit + " .. path)
end

local set_keymaps = function(config)
    vim.keymap.set("n", "<leader>nq", function()
        open_quicknotes(config.base_path .. "/" .. config.names.quicknotes)
    end, opts_with_desc("Open quick-notes file"))
end

local M = {}

M.setup = function(config_override)
    local config = vim.tbl_deep_extend("force", default_config, config_override)
    set_keymaps(config)
end

return M