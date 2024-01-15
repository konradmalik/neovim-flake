-- https://github.com/hrsh7th/vscode-langservers-extracted

vim.cmd("packadd SchemaStore.nvim")
local binaries = require("konrad.binaries")
local configs = require("konrad.lsp.configs")
local schemastore = require("schemastore")

return {
	config = {
		cmd = function() return { binaries.jsonls(), "--stdio" } end,
		init_options = {
			provideFormatter = false, -- use prettier instead
		},
		settings = {
			json = {
				format = false,
				validate = true,
				schemas = schemastore.json.schemas(),
			},
		},
		root_dir = function() return configs.root_dir(".git") end,
	},
}
