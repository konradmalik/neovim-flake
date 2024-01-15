local binaries = require("konrad.binaries")

return {
	filetypes = {
		"toml",
	},
	entry = {
		formatCommand = { binaries.taplo(), "format", "-" },
		formatStdin = true,
		formatCanRange = true,
	},
}
