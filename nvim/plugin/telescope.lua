-- NOTE: telescope has a hard nvim-web-devicons dependency
require("mini.icons").mock_nvim_web_devicons()

local actions = require("telescope.actions")
local conf = require("telescope.config").values
local finders = require("telescope.finders")
local layout = require("telescope.actions.layout")
local make_entry = require("telescope.make_entry")
local pickers = require("telescope.pickers")
local sorters = require("telescope.sorters")
local telescope = require("telescope")
local themes = require("telescope.themes")

local in_mappings = {
    ["<M-p>"] = layout.toggle_preview,
    ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
    ["<C-e>"] = actions.smart_add_to_qflist + actions.open_qflist,
    ["<C-l>"] = actions.smart_send_to_loclist + actions.open_loclist,
}

telescope.setup({
    defaults = {
        layout_strategy = "vertical",
        mappings = {
            i = in_mappings,
            n = in_mappings,
        },
        preview = {
            hide_on_startup = true,
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
telescope.load_extension("fzf")
telescope.load_extension("ui-select")

-- live grep where anything after two spaces is passed to rg as flags: "foo bar  -t lua -w"
local function live_grep_with_args()
    pickers
        .new({ preview = conf.preview }, {
            prompt_title = "Live Grep (rg flags after two spaces)",
            finder = finders.new_job(function(prompt)
                prompt = prompt or ""
                local pattern, flags = prompt:match("^(.-)%s%s+(.*)$")
                pattern = pattern or prompt
                if pattern == "" then return nil end
                local cmd = vim.list_extend({}, conf.vimgrep_arguments)
                vim.list_extend(cmd, vim.split(flags or "", "%s+", { trimempty = true }))
                return vim.list_extend(cmd, { "--", pattern })
            end, make_entry.gen_from_vimgrep({})),
            previewer = conf.grep_previewer({}),
            sorter = sorters.highlighter_only({}),
            push_cursor_on_edit = true,
            attach_mappings = function(_, map)
                map("i", "<C-g>", actions.to_fuzzy_refine)
                return true
            end,
        })
        :find()
end

local opts_with_desc = function(desc) return { desc = "[Telescope] " .. desc } end

local builtin = require("telescope.builtin")

vim.keymap.set("n", "<leader>ff", builtin.find_files, opts_with_desc("[F]ind [F]iles"))
vim.keymap.set("n", "<leader>fi", builtin.git_files, opts_with_desc("Find (G[i]t) Files"))
vim.keymap.set("n", "<leader>fg", live_grep_with_args, opts_with_desc("Live [G]rep"))
vim.keymap.set({ "n", "x" }, "<leader>f*", builtin.grep_string, opts_with_desc("Grep word under cursor"))
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
