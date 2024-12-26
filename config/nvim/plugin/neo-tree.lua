local keymap = vim.keymap
local mini_icons = require("mini.icons")
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
        icon = {
            provider = function(icon, node) -- setup a custom icon provider
                local text, hl = mini_icons.get(node.type, node.name)
                if node:is_expanded() then text = nil end

                if text then icon.text = text end
                if hl then icon.highlight = hl end
            end,
        },
        indent = {
            -- indent guides
            with_markers = true,
        },
        kind_icon = {
            provider = function(icon, node)
                icon.text, icon.highlight = mini_icons.get("lsp", node.extra.kind.name)
            end,
        },
    },
    event_handlers = {
        { event = events.FILE_MOVED, handler = on_move },
        { event = events.FILE_RENAMED, handler = on_move },
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
})
