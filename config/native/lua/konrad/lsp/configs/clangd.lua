local binaries = require("konrad.binaries")
local configs = require("konrad.lsp.configs")

local M = {}

M.config = {
	name = "clangd",
	cmd = { binaries.clangd() },
	root_dir = function()
		return configs.root_dir({
			".clangd",
			".clang-tidy",
			".clang-format",
			"compile_commands.json",
			"compile_flags.txt",
			"configure.ac",
			".git",
		})
	end,
}

return M
