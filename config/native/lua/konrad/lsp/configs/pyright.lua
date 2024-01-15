-- https://github.com/microsoft/pyright

local binaries = require("konrad.binaries")
local configs = require("konrad.lsp.configs")

return {
	config = {
		cmd = function() return { binaries.pyright(), "--stdio" } end,
		settings = {
			python = {
				analysis = {
					autoSearchPaths = true,
					useLibraryCodeForTypes = true,
					diagnosticMode = "openFilesOnly",
				},
			},
		},
		root_dir = function()
			return configs.root_dir({
				"pyproject.toml",
				"setup.py",
				"setup.cfg",
				"requirements.txt",
				"Pipfile",
				"pyrightconfig.json",
				".git",
			})
		end,
	},
}
