require("nvim-treesitter.configs").setup({
    ensure_installed = {},
    ignore_install = {},
    sync_install = false,
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
    indent = {
        enable = true,
    },
    textobjects = {
        select = {
            enable = true,
            lookahead = true,
            keymaps = {
                -- You can use the capture groups defined in textobjects.scm
                ["aa"] = {
                    query = "@parameter.outer",
                    desc = "Select outer part of an [a]rgument",
                },
                ["ia"] = {
                    query = "@parameter.inner",
                    desc = "Select inner part of an [a]rgument",
                },

                ["ak"] = {
                    query = "@conditional.outer",
                    desc = "Select outer part of a [k]onditional",
                },
                ["ik"] = {
                    query = "@conditional.inner",
                    desc = "Select inner part of a [k]onditional",
                },

                ["ai"] = {
                    query = "@loop.outer",
                    desc = "Select outer part of an [i]teration/loop",
                },
                ["ii"] = { query = "@loop.inner", desc = "Select inner part of a [i]teration/loop" },

                ["ac"] = {
                    query = "@call.outer",
                    desc = "Select outer part of a function [c]all",
                },
                ["ic"] = {
                    query = "@call.inner",
                    desc = "Select inner part of a function [c]all",
                },

                ["am"] = {
                    query = "@function.outer",
                    desc = "Select outer part of a [m]ethod/function definition",
                },
                ["im"] = {
                    query = "@function.inner",
                    desc = "Select inner part of a [m]ethod/function definition",
                },

                ["ao"] = { query = "@class.outer", desc = "Select outer part of an [o]bject/class" },
                ["io"] = { query = "@class.inner", desc = "Select inner part of an [o]bject/class" },
            },
        },
        move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
                ["]c"] = { query = "@call.outer", desc = "Next function [c]all" },
                ["]m"] = {
                    query = "@function.outer",
                    desc = "Next [m]ethod/function definition start",
                },
                ["]o"] = { query = "@class.outer", desc = "Next [o]bject/class start" },
                ["]k"] = {
                    query = "@conditional.outer",
                    desc = "Next [k]onditional start",
                },
                ["]i"] = { query = "@loop.outer", desc = "Next [i]teration/loop start" },
            },
            goto_next_end = {
                ["]C"] = { query = "@call.outer", desc = "Next function [c]all end" },
                ["]M"] = {
                    query = "@function.outer",
                    desc = "Next [m]ethod/function definition end",
                },
                ["]O"] = { query = "@class.outer", desc = "Next [o]bject/class end" },
                ["]K"] = { query = "@conditional.outer", desc = "Next [k]onditional end" },
                ["]I"] = { query = "@loop.outer", desc = "Next [i]teration/loop end" },
            },
            goto_previous_start = {
                ["[c"] = { query = "@call.outer", desc = "Previous function [c]all start" },
                ["[m"] = {
                    query = "@function.outer",
                    desc = "Previous [m]ethod/function definition start",
                },
                ["[o"] = { query = "@class.outer", desc = "Previous [o]bject/class start" },
                ["[k"] = {
                    query = "@conditional.outer",
                    desc = "Previous [k]onditional start",
                },
                ["[i"] = { query = "@loop.outer", desc = "Previous [i]teration/loop start" },
            },
            goto_previous_end = {
                ["[C"] = { query = "@call.outer", desc = "Previous function [c]all end" },
                ["[M"] = {
                    query = "@function.outer",
                    desc = "Previous [m]ethod/function definition end",
                },
                ["[O"] = { query = "@class.outer", desc = "Previous [o]bject/class end" },
                ["[K"] = { query = "@conditional.outer", desc = "Previous [k]onditional end" },
                ["[I"] = { query = "@loop.outer", desc = "Previous [i]teration/loop end" },
            },
        },
        swap = {
            enable = true,
            swap_next = {
                ["<leader>sna"] = {
                    query = "@parameter.inner",
                    desc = "swap parameters/argument with next",
                },
                ["<leader>snm"] = {
                    query = "@function.outer",
                    desc = "swap [m]ethod/function with next",
                },
            },
            swap_previous = {
                ["<leader>spa"] = {
                    query = "@parameter.inner",
                    desc = "Swap [a]rgument with previous",
                },
                ["<leader>spm"] = {
                    query = "@function.outer",
                    desc = "Swap [m]ethod/function with previous",
                },
            },
        },
    },
})

-- only enable after https://github.com/nvim-treesitter/nvim-treesitter-textobjects/issues/519 is fixed
-- local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")

-- -- vim way: ; goes to the direction you were moving.
-- vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
-- vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)

-- Optionally, make builtin f, F, t, T also repeatable with ; and ,
-- vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f)
-- vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F)
-- vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t)
-- vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T)
