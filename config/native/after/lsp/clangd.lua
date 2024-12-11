local binaries = require("pde.binaries")

vim.lsp.config("clangd", {
    cmd = { binaries.clangd() },
    root_markers = {
        ".clangd",
        ".clang-tidy",
        ".clang-format",
        "compile_commands.json",
        "compile_flags.txt",
        "configure.ac",
    },
    filetypes = { "c", "cpp" },
})
