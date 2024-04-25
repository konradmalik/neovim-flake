---only extra capabilities
vim.cmd.packadd({ "cmp-nvim-lsp", bang = true })
return require("cmp_nvim_lsp").default_capabilities()
