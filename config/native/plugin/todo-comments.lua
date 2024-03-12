local group = vim.api.nvim_create_augroup("todo-comments", { clear = true })
vim.api.nvim_create_autocmd("BufNew", {
    group = group,
    -- this plugin creates hl groups which forces a redraw,
    -- which makes intro screen flicker
    desc = "TODO comments deferred load",
    once = true,
    callback = function()
        local todo = require("todo-comments").setup()

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
})
