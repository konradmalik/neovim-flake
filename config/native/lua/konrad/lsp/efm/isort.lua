return {
    filetypes = { "python" },
    entry = {
        formatCommand = "isort --stdout --filename '${INPUT}' -",
        formatStdin = true,
    },
}
