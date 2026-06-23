if vim.b.did_ftplugin then return end

-- my treesitter-diagnostics plugin
vim.b.treesitter_diagnostics_disable = 1

-- Inherit most settings from jsonc.
vim.cmd("runtime! ftplugin/jsonc.vim")
vim.cmd("runtime! indent/jsonc.vim")

vim.treesitter.language.register("json", "hujson")

vim.bo.expandtab = false

vim.b.undo_ftplugin = (vim.b.undo_ftplugin or "") .. "\n setl expandtab<"

vim.b.did_ftplugin = true
