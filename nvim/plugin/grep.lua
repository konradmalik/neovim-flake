vim.o.grepprg = "rg --vimgrep --smart-case --hidden"

vim.api.nvim_create_autocmd("QuickFixCmdPost", {
    pattern = { "grep", "grepadd", "vimgrep", "vimgrepadd" },
    desc = "Open the quickfix window after grepping",
    callback = function() vim.cmd.cwindow() end,
})
