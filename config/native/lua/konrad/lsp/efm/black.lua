return {
    filetypes = { "python" },
    entry = {
        formatCommand = "black --no-color --quiet --stdin-filename '${INPUT}' -",
        formatStdin = true,
    },
}
