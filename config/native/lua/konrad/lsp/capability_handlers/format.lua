local format_is_enabled = true

---@param clientid integer
---@param bufnr integer
local format = function(clientid, bufnr)
	vim.lsp.buf.format({
		async = false,
		id = clientid,
		bufnr = bufnr,
	})
end

local M = {}
M.name = "Format"

---@param data table
---@return table of commands and buf_commands for this client
M.setup = function(data)
	local augroup = data.augroup
	local bufnr = data.bufnr
	local client = data.client

	vim.api.nvim_buf_create_user_command(bufnr, "AutoFormatToggle", function()
		format_is_enabled = not format_is_enabled
		print("Setting autoformatting to: " .. tostring(format_is_enabled))
	end, {
		desc = "Enable/disable autoformat with lsp",
	})

	vim.api.nvim_create_autocmd("BufWritePre", {
		desc = "AutoFormat on save",
		group = augroup,
		buffer = bufnr,
		callback = function()
			if not format_is_enabled then return end
			format(client.id, bufnr)
		end,
	})

	vim.api.nvim_buf_create_user_command(
		bufnr,
		"Format",
		function() format(client.id, bufnr) end,
		{ desc = "Format current buffer with LSP" }
	)

	return {
		commands = { "AutoFormatToggle" },
		buf_commands = { "Format" },
	}
end

return M
