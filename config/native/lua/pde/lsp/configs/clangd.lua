local binaries = require("pde.binaries")
local configs = require("pde.lsp.configs")

return {
    config = function()
        ---@type vim.lsp.ClientConfig
        return {
            name = "clangd",
            cmd = { binaries.clangd() },
            root_dir = configs.root_dir({
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
