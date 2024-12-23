require("pde.lsp").setup()

local enabled_configs = {
    "clangd",
    "efmson",
    "gopls",
    "golangci_lint",
    "gopls",
    "jsonls",
    "ltex",
    "lua_ls",
    "nixd",
    "prettier",
    "pyefm",
    "pyright",
    "rust_analyzer",
    "sh",
    "stylua",
    "taplo",
    "terraform-ls",
    "yamlls",
    "zls",
}

vim.lsp.config("*", {
    root_markers = {
        ".git",
    },
})

vim.lsp.enable(enabled_configs)
