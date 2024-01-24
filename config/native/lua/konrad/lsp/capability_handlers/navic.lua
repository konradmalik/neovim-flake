local M = {}
M.name = "Navic"

---@param data table
---@return table of commands and buf_commands for this client
M.setup = function(data)
	local bufnr = data.bufnr
	local client = data.client

	vim.cmd("packadd nvim-navic")
	require("nvim-navic").attach(client, bufnr)

	return {}
end

return M
