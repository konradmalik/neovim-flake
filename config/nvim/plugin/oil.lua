local oil = require("oil")
oil.setup({
    lsp_file_methods = {
        timeout_ms = 5000,
        autosave_changes = "unmodified",
    },
    keymaps = {
        ["gd"] = function() oil.set_columns({ "icon", "permissions", "size", "mtime" }) end,
        ["<C-q>"] = {
            "actions.send_to_qflist",
            desc = "Send files to QF list. If search is active, send only matching.",
            opts = { only_matching_search = true },
        },
    },
})

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
