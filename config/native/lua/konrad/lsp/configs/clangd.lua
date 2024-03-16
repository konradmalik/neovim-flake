local binaries = require("konrad.binaries")
local configs = require("konrad.lsp.configs")

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
