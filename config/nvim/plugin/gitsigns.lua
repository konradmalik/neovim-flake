require("lz.n").load({
    "gitsigns.nvim",
    event = { "BufNew", "BufRead" },
    after = function()
        local gitsigns = require("gitsigns")

        gitsigns.setup({
            signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
            numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
            linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
            word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
            current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`

            on_attach = function(bufnr)
                local opts_with_desc = function(desc)
                    return { desc = "[Gitsigns] " .. desc, buffer = bufnr }
                end

                vim.keymap.set(
                    "n",
                    "<leader>gq",
                    function() gitsigns.setqflist("all") end,
                    opts_with_desc("All Hunks to qf list")
                )
                vim.keymap.set(
                    "n",
                    "<leader>gl",
                    gitsigns.setloclist,
                    opts_with_desc("All current buffer hunks to loclist")
                )
                vim.keymap.set(
                    "n",
                    "<leader>gj",
                    function() gitsigns.nav_hunk("next") end,
                    opts_with_desc("Next Hunk")
                )
                vim.keymap.set(
                    "n",
                    "<leader>gk",
                    function() gitsigns.nav_hunk("prev") end,
                    opts_with_desc("Prev Hunk")
                )
                vim.keymap.set(
                    "n",
                    "<leader>gp",
                    gitsigns.preview_hunk,
                    opts_with_desc("Preview Hunk")
                )
                vim.keymap.set("n", "<leader>gr", gitsigns.reset_hunk, opts_with_desc("Reset Hunk"))
                vim.keymap.set(
                    "n",
                    "<leader>gR",
                    gitsigns.reset_buffer,
                    opts_with_desc("Reset Buffer")
                )
                vim.keymap.set("n", "<leader>gs", gitsigns.stage_hunk, opts_with_desc("Stage Hunk"))
                vim.keymap.set(
                    "n",
                    "<leader>gu",
                    gitsigns.undo_stage_hunk,
                    opts_with_desc("Undo Stage Hunk")
                )
            end,
        })
    end,
})
