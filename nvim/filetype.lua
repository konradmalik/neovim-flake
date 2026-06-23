vim.filetype.add({
    filename = {
        condarc = "yaml",
        ["composer.lock"] = "json",
        Tiltfile = "python",
    },
    extension = {
        hujson = "hujson",
    },
})
