local actions = require("telescope.actions")
local layout = require("telescope.actions.layout")
local telescope = require("telescope")
local themes = require("telescope.themes")

telescope.setup({
    defaults = {
        layout_strategy = "vertical",
        layout_config = {
            vertical = {
                height = 0.9,
                width = 0.9,
            },
        },
        mappings = {
            i = {
                ["<C-p>"] = layout.toggle_preview,
                ["<C-Q>"] = actions.send_selected_to_qflist,
            },
            n = {
                ["<C-Q>"] = actions.send_selected_to_qflist,
            },
        },
        path_display = {
            filename_first = {
                reverse_directories = true,
            },
        },
        preview = {
            hide_on_startup = true, -- hide previewer when picker starts
        },
        prompt_prefix = " ",
        selection_caret = "󰁕 ",
    },
    extensions = {
        ["ui-select"] = {
            themes.get_dropdown(),
        },
    },
})
-- To get extensions loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
telescope.load_extension("fzf")
telescope.load_extension("ui-select")

local opts_with_desc = function(desc) return { desc = "[Telescope] " .. desc } end

local builtin = require("telescope.builtin")

vim.keymap.set("n", "<leader>ff", builtin.find_files, opts_with_desc("[F]ind [F]iles"))
vim.keymap.set("n", "<leader>fi", builtin.git_files, opts_with_desc("Find (G[i]t) Files"))
vim.keymap.set("n", "<leader>fg", builtin.live_grep, opts_with_desc("Live [G]rep"))
vim.keymap.set("n", "<leader>f*", builtin.grep_string, opts_with_desc("Grep word under cursor"))
vim.keymap.set(
    "n",
    "<leader>f/",
    function()
        builtin.current_buffer_fuzzy_find(themes.get_dropdown({
            winblend = 10,
            previewer = false,
        }))
    end,
    opts_with_desc("[/] Fuzzily search in current buffer")
)
vim.keymap.set("n", "<leader>fb", builtin.buffers, opts_with_desc("[B]uffers"))
vim.keymap.set("n", "<leader>fh", builtin.help_tags, opts_with_desc("[H]elp Tags"))
vim.keymap.set("n", "<leader>fq", builtin.diagnostics, opts_with_desc("Diagnostics"))
vim.keymap.set("n", "<leader>f.", builtin.resume, opts_with_desc("Repeat [.] last panel"))
vim.keymap.set("n", "<leader>fc", builtin.commands, opts_with_desc("Find [C]ommands"))
vim.keymap.set("n", "<leader>fm", builtin.keymaps, opts_with_desc("Find key[m]aps"))
vim.keymap.set("n", "<leader>fo", builtin.oldfiles, opts_with_desc("Find [o]ldfiles"))
-- git
vim.keymap.set("n", "<leader>gS", builtin.git_status, opts_with_desc("Git [S]tatus"))
vim.keymap.set("n", "<leader>gb", builtin.git_branches, opts_with_desc("Git [b]ranches"))
vim.keymap.set("n", "<leader>gc", builtin.git_commits, opts_with_desc("Git [c]ommits"))
