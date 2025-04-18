require("pde.lsp").setup()

vim.lsp.config("*", {
    root_markers = {
        ".git",
    },
})

vim.lsp.enable({
    "clangd",
    "efmson",
    "gopls",
    "golangci_lint",
    "gopls",
    "jsonls",
    "ltex_plus",
    "lua_ls",
    "nixd",
    "prettier",
    "pyefm",
    "basedpyright",
    "rust_analyzer",
    "sh",
    "stylua",
    "taplo",
    "terraform-ls",
    "yamlls",
    "zls",
})
