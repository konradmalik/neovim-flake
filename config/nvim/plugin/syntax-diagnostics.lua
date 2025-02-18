local autocmd_group = vim.api.nvim_create_augroup("editor.treesitter", { clear = true })

vim.api.nvim_create_autocmd({ "FileType", "TextChanged", "InsertLeave" }, {
    desc = "treesitter diagnostics",
    group = autocmd_group,
    callback = function(args) require("pde.syntax-diagnostics").diagnose(args.buf) end,
})
