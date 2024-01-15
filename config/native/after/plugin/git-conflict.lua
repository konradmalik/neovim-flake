require("git-conflict").setup({
	highlights = {
		current = "diffAdded",
		incoming = "diffChanged",
		ancestor = "diffDeleted",
	},
})
