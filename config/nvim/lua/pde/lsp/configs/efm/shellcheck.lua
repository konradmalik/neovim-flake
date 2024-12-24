local binaries = require("pde.binaries")

---@type EfmPlugin
return {
    filetypes = { "sh" },
    entry = {
        lintCommand = { binaries.shellcheck(), "--color=never", "--format=gcc", "-" },
        lintStdin = true,
        lintFormats = {
            "-:%l:%c: %trror: %m",
            "-:%l:%c: %tarning: %m",
            "-:%l:%c: %tote: %m",
        },
        lintSource = "shellcheck",
    },
}
