local fs = require("konrad.fs")

local autostart_enabled = true

local initialized = false
local initialize_once = function()
	if initialized then return end

	require("konrad.lsp.borders")
	require("konrad.lsp.commands")

	require("konrad.lsp.progress")

	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("personal-lsp-attach", { clear = true }),
		callback = function(args)
			local client_id = args.data.client_id
			local client = vim.lsp.get_client_by_id(client_id)
			local bufnr = args.buf
			if client then
				require("konrad.lsp.event_handlers").attach(client, bufnr)
			else
				vim.notify("cannot find client " .. client_id, vim.log.levels.ERROR)
			end
		end,
	})

	vim.api.nvim_create_autocmd("LspDetach", {
		group = vim.api.nvim_create_augroup("personal-lsp-detach", { clear = true }),
		callback = function(args)
			local client_id = args.data.client_id
			local client = vim.lsp.get_client_by_id(client_id)
			local bufnr = args.buf
			if client then
				require("konrad.lsp.event_handlers").detach(client, bufnr)
			else
				vim.notify("cannot find client " .. client_id, vim.log.levels.ERROR)
			end
		end,
	})

	initialized = true
end

local M = {}

M.toggle_autostart = function() autostart_enabled = not autostart_enabled end

function M.is_autostart_enabled() return autostart_enabled end

---starts if needed and attaches to the current buffer
---respects LspAutostartToggle
---@param config table
---@param bufnr integer? buffer to attach to
---@param force boolean? whether to start even if autostart is disabled
M.start_and_attach = function(config, bufnr, force)
	if not force and not autostart_enabled then
		vim.notify_once("LSP autostart is disabled", vim.log.levels.INFO)
		return
	end

	bufnr = bufnr or 0
	if not fs.is_buf_readable_file(bufnr) then return end

	initialize_once()

	local made_config = require("konrad.lsp.configs").make_config(config)
	local client_id = vim.lsp.start(made_config, { bufnr = bufnr })
	if not client_id then vim.notify("cannot start lsp: " .. made_config.cmd[1], vim.log.levels.ERROR) end
end

return M
