local keymap = vim.keymap
local opts_with_desc = function(desc) return { desc = "[NeoTree] " .. desc } end

keymap.set(
    "n",
    "<leader>tt",
    "<cmd>Neotree focus filesystem left toggle<cr>",
    opts_with_desc("Toggle")
)

local events = require("neo-tree.events")
local neo_tree = require("neo-tree")

local function on_move(data) require("snacks").rename.on_rename_file(data.source, data.destination) end

neo_tree.setup({
    sources = {
        "filesystem",
    },
    sort_case_insensitive = true, -- used when sorting files and directories in the tree
    default_component_configs = {
        indent = {
            -- indent guides
            with_markers = true,
        },
    },
    filesystem = {
        filtered_items = {
            visible = true, -- when true, they will just be displayed differently than normal items
            hide_dotfiles = true,
            hide_gitignored = true,
        },
        use_libuv_file_watcher = true,
        follow_current_file = {
            enabled = true,
        },
    },
    event_handlers = {
        { event = events.FILE_MOVED, handler = on_move },
        { event = events.FILE_RENAMED, handler = on_move },
    },
})
