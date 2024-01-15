local codelens_is_enabled = true

local M = {}

---@param data table
---@return table of commands and buf_commands for this client
M.attach = function(data)
	local keymapper = require("konrad.lsp.keymapper")

	local augroup = data.augroup
	local bufnr = data.bufnr

	vim.api.nvim_create_user_command("CodeLensToggle", function()
		codelens_is_enabled = not codelens_is_enabled
		if not codelens_is_enabled then vim.schedule(vim.lsp.codelens.clear) end
		print("Setting codelens to: " .. tostring(codelens_is_enabled))
	end, {
		desc = "Enable/disable codelens with lsp",
	})

	vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "CursorHold", "InsertLeave" }, {
		group = augroup,
		buffer = bufnr,
		callback = function()
			if not codelens_is_enabled then return end
			vim.schedule(vim.lsp.codelens.refresh)
		end,
		desc = "Refresh codelens",
	})

	local opts_with_desc = keymapper.opts_for(bufnr)

	vim.api.nvim_buf_create_user_command(
		bufnr,
		"CodeLensRefresh",
		vim.lsp.codelens.refresh,
		{ desc = "Refresh codelens for the current buffer" }
	)
	vim.keymap.set("n", "<leader>cl", vim.lsp.codelens.run, opts_with_desc("CodeLens run"))

	-- refresh manually right now for a start
	if codelens_is_enabled then vim.schedule(vim.lsp.codelens.refresh) end
	return {
		commands = { "CodeLensToggle" },
		buf_commands = { "CodeLensRefresh" },
	}
end

M.detach = function() pcall(vim.lsp.codelens.clear) end

return M
