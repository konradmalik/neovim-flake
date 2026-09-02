if vim.b.did_md_ftplugin then return end

require("pde.img").attach(vim.api.nvim_get_current_buf())

vim.b.did_md_ftplugin = true
