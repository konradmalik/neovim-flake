require("oil").setup()

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

local group = vim.api.nvim_create_augroup("oil-lsp-rename", { clear = true })
vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "OilActionsPost",
    callback = function(event)
        if event.data.actions.type == "move" then
            require("rename").on_rename_file(
                event.data.actions.src_url,
                event.data.actions.dest_url
            )
        end
    end,
})
