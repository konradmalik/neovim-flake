local inlayhints_is_enabled = true

local M = {}
M.name = "InlayHints"

---@param data table
---@return table of commands and buf_commands for this client
M.attach = function(data)
	local bufnr = data.bufnr
	local augroup = data.augroup

	vim.api.nvim_create_autocmd("InsertEnter", {
		group = augroup,
		buffer = bufnr,
		callback = function()
			if not inlayhints_is_enabled then return end
			vim.lsp.inlay_hint.enable(bufnr, true)
		end,
	})
	vim.api.nvim_create_autocmd("InsertLeave", {
		group = augroup,
		buffer = bufnr,
		callback = function()
			if not inlayhints_is_enabled then return end
			pcall(vim.lsp.inlay_hint.enable, bufnr, false)
		end,
	})

	vim.api.nvim_buf_create_user_command(bufnr, "InlayHintsToggle", function()
		inlayhints_is_enabled = not inlayhints_is_enabled
		if not inlayhints_is_enabled then
			for _, buf in ipairs(vim.api.nvim_list_bufs()) do
				pcall(vim.lsp.inlay_hint.enable, buf, false)
			end
		end
		print("Setting inlayhints to: " .. tostring(inlayhints_is_enabled))
	end, {
		desc = "Enable/disable inlayhints with lsp",
	})

	return {
		commands = { "InlayHintsToggle" },
	}
end

M.detach = function(data)
	local bufnr = data.bufnr
	pcall(vim.lsp.inlay_hint.enable, bufnr, false)
end

return M
