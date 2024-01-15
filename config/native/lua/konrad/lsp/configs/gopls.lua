-- https://github.com/golang/tools/tree/master/gopls

local binaries = require("konrad.binaries")
local configs = require("konrad.lsp.configs")
return {
	config = {
		cmd = function() return { binaries.gopls() } end,
		-- https://github.com/golang/tools/blob/master/gopls/doc/settings.md
		settings = {
			gopls = {
				allExperiments = true,
			},
		},
		root_dir = function() return configs.root_dir({ "go.work", "go.mod", ".git" }) end,
	},
}
