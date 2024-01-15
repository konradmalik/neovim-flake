require("konrad.heirline").setup({
	specialBufferMatches = {
		buftype = { "nofile", "prompt", "help", "quickfix" },
		filetype = { "^git.*", "fugitive", "harpoon", "undotree", "diff" },
	},
})
