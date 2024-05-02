local binaries = require("pde.binaries")

return {
    config = function()
        ---@type vim.lsp.ClientConfig
        return {
            name = "clangd",
            cmd = { binaries.clangd() },
            root_dir = vim.fs.root(0, {
                ".clangd",
                ".clang-tidy",
                ".clang-format",
                "compile_commands.json",
                "compile_flags.txt",
                "configure.ac",
                ".git",
            }),
        }
    end,
}
