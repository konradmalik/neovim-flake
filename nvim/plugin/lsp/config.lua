require("pde.loader").add_to_on_reset(
    function() vim.fs.rm(vim.lsp.log.get_filename(), { force = true }) end
)

vim.lsp.log.set_level(vim.log.levels.WARN)

vim.lsp.config("*", { capabilities = vim.lsp.protocol.make_client_capabilities() })
vim.lsp.enable({
    "clangd",
    "golangci_lint_ls",
    "gopls",
    "gopls",
    "harper_ls",
    "json_fl",
    "jsonls",
    "lua_ls",
    "marksman",
    "nixd",
    "prettier",
    "py_fl",
    "roslyn_ls",
    "rust_analyzer",
    "sh",
    "stylua",
    "taplo",
    "terraformls",
    "ty",
    "yamlls",
    "zls",
})
