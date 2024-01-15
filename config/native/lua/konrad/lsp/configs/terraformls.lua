-- https://github.com/hashicorp/terraform-ls

local binaries = require("konrad.binaries")
local configs = require("konrad.lsp.configs")
return {
	config = {
		cmd = function() return { binaries.terraformls(), "serve" } end,
		root_dir = function() return configs.root_dir({ ".terraform", ".git" }) end,
	},
}
