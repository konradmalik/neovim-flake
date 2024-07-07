-- https://github.com/nix-community/nixd

local binaries = require("pde.binaries")

return {
    ---@param bufnr integer
    ---@return vim.lsp.ClientConfig
    config = function(bufnr)
        ---@type vim.lsp.ClientConfig
        return {
            name = "nixd",
            cmd = { binaries.nixd() },
            settings = {
                nixd = {
                    formatting = {
                        command = { binaries.nixfmt() },
                    },
                },
            },
            root_dir = vim.fs.root(bufnr, { "flake.nix", ".git" }),
        }
    end,
}
