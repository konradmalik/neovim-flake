local components = require("konrad.statusline.components")
local conditions = require("konrad.statusline.conditions")
local utils = require("konrad.statusline.utils")

local config = {
	special = {
		filetype = { "^git.*", "fugitive", "harpoon", "undotree", "diff" },
		buftype = { "nofile", "prompt", "help", "quickfix" },
	},
}

local function setup_statusline()
	vim.g.qf_disable_statusline = true
	vim.o.laststatus = 3
	vim.api.nvim_set_hl(0, "StatusLine", { bg = "bg", fg = "fg" })
	vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "fg", fg = "bg" })

	vim.o.statusline = "%!v:lua.require('konrad.statusline').statusline()"
end

local function is_special(bufnr) return conditions.buffer_matches(config.special, bufnr) end

local function setup_local_winbar_with_autocmd()
	local winbar = "%!v:lua.require('konrad.statusline').winbar()"
	local group = vim.api.nvim_create_augroup("personal-winbar", { clear = true })
	vim.api.nvim_create_autocmd({ "VimEnter", "UIEnter", "BufWinEnter", "FileType", "TermOpen" }, {
		group = group,
		callback = function(event)
			if event.event == "VimEnter" or event.event == "UIEnter" then
				for _, win in ipairs(vim.api.nvim_list_wins()) do
					local winbuf = vim.api.nvim_win_get_buf(win)
					if is_special(winbuf) then
						if vim.wo[win].winbar == winbar then vim.wo[win].winbar = nil end
					else
						vim.wo[win].winbar = winbar
					end
				end
			end

			if is_special(event.buf) then
				if vim.wo.winbar == winbar then vim.wo.winbar = nil end
				return
			end

			vim.wo.winbar = winbar
		end,
		desc = "Personal: set window-local winbar",
	})
end

local M = {}

M.statusline = function()
	if is_special(utils.stbufnr()) then return components.filetype() end

	return table.concat({
		components.mode(),
		components.space,
		components.space,
		components.git(),
		components.space,
		components.gitchanges(),
		components.align,
		components.diagnostics(),
		components.space,
		components.LSP_status(),
		components.space,
		components.filetype(),
		components.space,
		components.fileformat(),
		components.space,
		components.file_encoding(),
		components.space,
		components.hostname(),
		components.space,
		components.ruler(),
		components.space,
		components.scrollbar(),
	})
end

M.winbar = function()
	if not conditions.is_activewin() then return components.fileinfo(false, true) end

	return table.concat({
		components.cwd(true),
		components.space,
		components.fileinfo(true, true),
		components.space,
		components.navic(),
	})
end

M.setup = function(conf)
	config = vim.tbl_deep_extend("force", config, conf or {})

	setup_statusline()
	setup_local_winbar_with_autocmd()
end

return M
