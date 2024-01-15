local M = {}

-- client id to group id mapping
local _augroups = {}

---@param client table
---@return integer
M.get_augroup = function(client)
	if not _augroups[client.id] then
		local group_name = string.format("personal-lsp-%s-%d", client.name, client.id)
		local group = vim.api.nvim_create_augroup(group_name, { clear = true })
		_augroups[client.id] = group
		return group
	end
	return _augroups[client.id]
end

---@param augroup integer
---@param bufnr integer
local del_autocmds_for_buf = function(augroup, bufnr)
	local aucmds = vim.api.nvim_get_autocmds({
		group = augroup,
		buffer = bufnr,
	})
	for _, aucmd in ipairs(aucmds) do
		pcall(vim.api.nvim_del_autocmd, aucmd.id)
	end
end

---@param client table
---@param bufnr integer
M.del_autocmds_for_buf = function(client, bufnr)
	local augroup = M.get_augroup(client)
	del_autocmds_for_buf(augroup, bufnr)
end

return M
