local fidget_ok, fidget = pcall(require, "fidget")
if not fidget_ok then
    vim.notify("cannot load fidget")
    return false
end

fidget.setup {
    text = {
        spinner = "dots",
    },
    window = {
        relative = "editor",
    },
}
