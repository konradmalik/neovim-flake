require("kanagawa").setup({
	compile = true,
	background = {
		dark = "wave",
		light = "lotus",
	},
})

vim.opt.background = "dark"
vim.cmd("colorscheme kanagawa")
