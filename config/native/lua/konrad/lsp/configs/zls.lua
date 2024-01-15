-- https://github.com/zigtools/zls

local binaries = require("konrad.binaries")
local configs = require("konrad.lsp.configs")
return {
	config = {
		cmd = function() return { binaries.zls() } end,
		root_dir = function() return configs.root_dir({ "zls.json", ".git" }) end,
	},
}
