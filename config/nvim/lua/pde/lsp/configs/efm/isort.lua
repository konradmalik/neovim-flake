---@type EfmPlugin
return {
    filetypes = { "python" },
    entry = {
        formatCommand = { "isort", "--quiet", "-" },
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
