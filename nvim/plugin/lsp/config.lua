-- runs before any client starts writing, so the log can be removed safely
local log_file = vim.lsp.log.get_filename()
local log_stat = vim.uv.fs_stat(log_file)
if log_stat and log_stat.size > 512 * 1024 * 1024 then vim.fs.rm(log_file) end

vim.lsp.log.set_level(vim.log.levels.WARN)

vim.lsp.enable({
    "bashls",
    "clangd",
    "golangci_lint_ls",
    "gopls",
    "harper_ls",
    "jsonls",
    "lua_ls",
    "marksman",
    "nixd",
    "nvim_ls",
    "roslyn_ls",
    "ruff",
    "rust_analyzer",
    "terraformls",
    "ty",
    "yamlls",
    "zls",
})
