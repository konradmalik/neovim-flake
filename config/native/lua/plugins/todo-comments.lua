return {
    "todo-comments-nvim",
    event = { "BufNew", "BufRead" },
    after = function()
        local todo = require("todo-comments")
        todo.setup({ signs = false })

        local opts_with_desc = function(desc) return { desc = "[todo-comments] " .. desc } end

        vim.keymap.set(
            "n",
            "]n",
            function() todo.jump_next() end,
            opts_with_desc("Next todo [n]ote")
        )
        vim.keymap.set(
            "n",
            "[n",
            function() todo.jump_prev() end,
            opts_with_desc("Previous todo [n]ote")
        )
        vim.keymap.set(
            "n",
            "<leader>fn",
            "<cmd>TodoTelescope<cr>",
            opts_with_desc("Find all todo [n]otes")
        )
    end,
}
