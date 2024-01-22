vim.o.laststatus = 3

local components = require("konrad.statusline.components")

local config = {
	special_filetype = { "^git.*", "fugitive", "harpoon", "undotree", "diff" },
	special_buftype = { "nofile", "prompt", "help", "quickfix" },
}

local function is_activewin() return vim.api.nvim_get_current_win() == vim.g.statusline_winid end

local is_special = function(bufnr)
	local filetype = vim.bo[bufnr].filetype
	if filetype then
		for _, ex in ipairs(config.special_filetype) do
			if filetype:match(ex) then return true end
		end
	end

	local buftype = vim.bo[bufnr].buftype
	if buftype then
		for _, ex in ipairs(config.special_buftype) do
			if buftype:match(ex) then return true end
		end
	end

	return false
end

local M = {}

M.statusline_special = function() return components.filetype() end

M.statusline = function()
	return table.concat({
		components.mode(),
		" ",
		components.git(),
		" ",
		components.gitchanges(),
		"%=",
		components.diagnostics(),
		"  ",
		components.LSP_status(),
		"  ",
		components.filetype(),
		" ",
		components.fileformat(),
		" ",
		components.file_encoding(),
		" ",
		components.hostname(),
		" ",
		components.ruler(),
		" ",
		components.scrollbar(),
	})
end

M.winbar = function()
	if not is_activewin() then return table.concat({
		components.fileinfo(false),
	}) end

	return table.concat({
		components.cwd(),
		" ",
		components.fileinfo(true),
		" ",
		components.navic(),
	})
end

M.setup = function(conf)
	config = vim.tbl_deep_extend("force", config, conf or {})

	local group = vim.api.nvim_create_augroup("personal-statusbar-winbar", { clear = true })
	vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter", "FileType" }, {
		group = group,
		pattern = "*",
		callback = function(event)
			local bufnr = event.buf
			if is_special(bufnr) then
				vim.opt_local.winbar = nil
				vim.opt_local.statusline = "%!v:lua.require('konrad.statusline').statusline_special()"
				return
			end

			vim.opt_local.winbar = "%!v:lua.require('konrad.statusline').winbar()"
			vim.opt_local.statusline = "%!v:lua.require('konrad.statusline').statusline()"
		end,
	})
end

return M
