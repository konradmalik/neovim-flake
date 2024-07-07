local binaries = require("pde.binaries")
---@type EfmPlugin
return {
    filetypes = { "python" },
    entry = {
        formatCommand = {
            binaries.black(),
            "--no-color",
            "--quiet",
            "-",
        },
        formatStdin = true,
        rootMarkers = {
            "pyproject.toml",
            "setup.cfg",
            "setup.py",
            "requirements.txt",
            "requirements-dev.txt",
        },
    },
}
