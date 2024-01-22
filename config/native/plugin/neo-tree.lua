local keymap = vim.keymap
local opts_with_desc = function(desc) return { desc = "[NeoTree] " .. desc } end

keymap.set("n", "<leader>tt", "<cmd>Neotree focus filesystem left toggle<cr>", opts_with_desc("Toggle"))

local neo_tree = require("neo-tree")

local icons = require("konrad.icons")
local git_icons = icons.git
local docs_icons = icons.documents
local lines_icons = icons.lines
local ui_icons = icons.ui

neo_tree.setup({
	sources = {
		"filesystem",
	},
	sort_case_insensitive = true, -- used when sorting files and directories in the tree
	default_component_configs = {
		indent = {
			-- indent guides
			with_markers = true,
			indent_marker = lines_icons.Edge,
			last_indent_marker = lines_icons.Corner,
			-- expander config, needed for nesting files
			with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
			expander_collapsed = ui_icons.FoldClosed,
			expander_expanded = ui_icons.FoldOpen,
		},
		icon = {
			folder_closed = docs_icons.Folder,
			folder_open = docs_icons.OpenFolder,
			folder_empty = docs_icons.EmptyFolder,
			default = "*",
		},
		modified = {
			symbol = ui_icons.Square,
		},
		git_status = {
			symbols = {
				-- Change type
				added = git_icons.Add,
				modified = git_icons.Mod,
				deleted = git_icons.Deleted,
				renamed = git_icons.Rename,
				-- Status type
				untracked = git_icons.Untracked,
				ignored = git_icons.Ignore,
				unstaged = git_icons.Unstaged,
				staged = git_icons.Staged,
				conflict = git_icons.Unmerged,
			},
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
})
