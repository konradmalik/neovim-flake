local opts_with_desc = function(desc) return { desc = "[notes] " .. desc } end

local default_config = {
    -- may be function as well
    base_path = "/tmp/notes",
    names = {
        quicknotes = "notes.md",
    },
}

---@param path string
local open_quicknotes = function(path) vim.cmd("botright vsplit + " .. path) end

local set_keymaps = function(config)
    vim.keymap.set(
        "n",
        "<leader>nq",
        function() open_quicknotes(config.base_path .. "/" .. config.names.quicknotes) end,
        opts_with_desc("Open quick-notes file")
    )
end

local M = {}

M.setup = function(config_override)
    local config = vim.tbl_deep_extend("force", default_config, config_override)

    if type(config.base_path) == "function" then config.base_path = config.base_path() end

    set_keymaps(config)
end

return M
