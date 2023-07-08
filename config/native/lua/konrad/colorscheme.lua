local kanagawa_ok, kanagawa = pcall(require, "kanagawa")
if not kanagawa_ok then
    vim.notify("cannot load kanagawa")
    return
end

kanagawa.setup({
    compile = true,
    background = {
        dark = "wave",
        light = "lotus"
    },
})

vim.o.background = "dark";
vim.cmd("colorscheme kanagawa")
