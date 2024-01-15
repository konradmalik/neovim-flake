local M = {}

---@param name string
---@param packadds string[]
---@param fun function
---@param opts table|nil
function M.make_enable_command(name, packadds, fun, opts)
	vim.api.nvim_create_user_command(name, function()
		vim.api.nvim_del_user_command(name)
		for _, value in ipairs(packadds) do
			vim.cmd("packadd " .. value)
		end
		fun()
	end, opts or {})
end

return M
