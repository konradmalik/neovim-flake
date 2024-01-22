local devicons = require("nvim-web-devicons")
local icons = require("konrad.icons")

local function stwinnr() return vim.g.statusline_winid end

local function stbufnr() return vim.api.nvim_win_get_buf(vim.g.statusline_winid) end

local function wrap_hl(hl, s) return string.format("%%#%s#%s%%*", hl, s) end

local colors = {
	green = "String",
	blue = "Function",
	gray = "NonText",
	orange = "Constant",
	purple = "Statement",
	cyan = "Special",
	diag_warn = "DiagnosticWarn",
	diag_error = "DiagnosticError",
	diag_hint = "DiagnosticHint",
	diag_info = "DiagnosticInfo",
	git_del = "diffDeleted",
	git_add = "diffAdded",
	git_change = "diffChanged",
	directory = "Directory",
	filetype = "Type",
	text = "Normal",
	debug = "Debug",
}

local sbar = icons.ui.Animations.ThinFill

local format_types = {
	unix = icons.oss.Linux,
	mac = icons.oss.Mac,
	dos = icons.oss.Windows,
}

local modes = {
	["n"] = { "N", colors.blue },
	["no"] = { "N?", colors.blue },
	["nov"] = { "N?", colors.blue },
	["noV"] = { "N?", colors.blue },
	["no\22"] = { "N?", colors.blue },
	["niI"] = { "Ni", colors.blue },
	["niR"] = { "Nr", colors.blue },
	["niV"] = { "Nv", colors.blue },
	["nt"] = { "Nt", colors.blue },
	["ntT"] = { "Nt", colors.blue },

	["v"] = { "V", colors.cyan },
	["vs"] = { "Vs", colors.cyan },
	["V"] = { "V_", colors.cyan },
	["Vs"] = { "Vs", colors.cyan },
	[""] = { "^V", colors.cyan },
	["s"] = { "^V", colors.cyan },

	["s"] = { "S", colors.purple },
	["S"] = { "S_", colors.purple },
	[""] = { "^S", colors.purple },

	["i"] = { "I", colors.green },
	["ic"] = { "Ic", colors.green },
	["ix"] = { "Ix", colors.green },

	["R"] = { "R", colors.orange },
	["Rc"] = { "Rc", colors.orange },
	["Rx"] = { "Rx", colors.orange },
	["Rv"] = { "Rv", colors.orange },
	["Rvc"] = { "Rv", colors.orange },
	["Rvx"] = { "Rv", colors.orange },

	["c"] = { "c", colors.orange },
	["cv"] = { "Ex", colors.orange },
	["ce"] = { "Ex", colors.orange },
	["r"] = { "...", colors.orange },
	["rm"] = { "M", colors.orange },
	["r?"] = { "?", colors.orange },
	["!"] = { "!", colors.orange },

	["x"] = { "X", colors.purple },

	["t"] = { "T", colors.blue },
}

local M = {}

M.space = " "

M.align = "%="

-- this means that the statusline is cut here when there's not enough space
M.cut = "%<"

M.mode = function()
	local m = vim.api.nvim_get_mode().mode
	local mname = modes[m][1]
	local mhl = modes[m][2]
	local hl = vim.api.nvim_get_hl(0, { name = mhl })

	local left = wrap_hl(mhl, icons.ui.LeftHalf)
	local right = wrap_hl(mhl, icons.ui.RightHalf)

	vim.api.nvim_set_hl(0, "StMode", { bold = true, bg = hl.fg, fg = "bg" })
	local mode = wrap_hl("StMode", string.format("%s %s", icons.misc.Neovim, mname))

	return string.format("%s%s%s", left, mode, right)
end

M.fileinfo = function(active)
	local text = {}

	local bufname = vim.api.nvim_buf_get_name(stbufnr())
	local extension = vim.fn.fnamemodify(bufname, ":e")
	local icon, color = devicons.get_icon_color(bufname, extension, { default = true })
	vim.api.nvim_set_hl(0, "StFileInfo", { fg = color })
	table.insert(text, wrap_hl("StFileInfo", string.format("%s ", icon)))

	local filename = nil
	if bufname == "" then
		filename = "[No Name]"
	elseif vim.bo[stbufnr()].filetype == "help" then
		filename = vim.fn.fnamemodify(bufname, ":t")
	else
		filename = vim.fn.fnamemodify(bufname, ":.")
	end

	if vim.o.columns <= 85 then filename = vim.fn.pathshorten(filename) end
	table.insert(text, filename)

	if vim.bo[stbufnr()].modified then table.insert(text, wrap_hl(colors.diag_info, icons.ui.SmallCircle)) end
	if vim.bo[stbufnr()].readonly then table.insert(text, wrap_hl(colors.diag_warn, icons.ui.Lock)) end
	if not vim.bo[stbufnr()].modifiable then table.insert(text, wrap_hl(colors.diag_error, icons.ui.FilledLock)) end

	local hl = ""
	if active then
		hl = colors.text
	else
		hl = colors.gray
	end
	return wrap_hl(hl, table.concat(text))
end

M.fileformat = function() return wrap_hl(colors.gray, format_types[vim.bo[stbufnr()].fileformat]) end

M.git = function()
	if not vim.b[stbufnr()].gitsigns_head or vim.b[stbufnr()].gitsigns_git_status then return "" end

	return wrap_hl(colors.orange, string.format("%s %s", icons.git.Branch, vim.b[stbufnr()].gitsigns_status_dict.head))
end

M.gitchanges = function()
	if not vim.b[stbufnr()].gitsigns_head or vim.b[stbufnr()].gitsigns_git_status or vim.o.columns < 120 then
		return ""
	end

	local git_status = vim.b[stbufnr()].gitsigns_status_dict

	local added = (git_status.added and git_status.added ~= 0)
			and wrap_hl(colors.git_add, string.format("%s %s ", icons.git.Add, git_status.added))
		or ""
	local changed = (git_status.changed and git_status.changed ~= 0)
			and wrap_hl(colors.git_change, string.format("%s %s ", icons.git.Mod, git_status.changed))
		or ""
	local removed = (git_status.removed and git_status.removed ~= 0)
			and wrap_hl(colors.git_del, string.format("%s %s ", icons.git.Remove, git_status.removed))
		or ""

	return string.format("%s%s%s", added, changed, removed)
end

M.diagnostics = function()
	local numErrors = #vim.diagnostic.get(stbufnr(), { severity = vim.diagnostic.severity.ERROR }) or 0
	local numWarnings = #vim.diagnostic.get(stbufnr(), { severity = vim.diagnostic.severity.WARN }) or 0
	local numHints = #vim.diagnostic.get(stbufnr(), { severity = vim.diagnostic.severity.HINT }) or 0
	local numInfo = #vim.diagnostic.get(stbufnr(), { severity = vim.diagnostic.severity.INFO }) or 0

	local errors = wrap_hl(colors.diag_error, string.format("%s %s ", icons.diagnostics.Error, numErrors))
	local warnings = wrap_hl(colors.diag_warn, string.format("%s %s ", icons.diagnostics.Warning, numWarnings))
	local hints = wrap_hl(colors.diag_hint, string.format("%s %s ", icons.diagnostics.Hint, numHints))
	local info = wrap_hl(colors.diag_info, string.format("%s %s ", icons.diagnostics.Information, numInfo))

	return vim.o.columns > 140 and string.format("%s%s%s%s", errors, warnings, hints, info) or ""
end

M.filetype = function()
	local ft = vim.bo[stbufnr()].filetype
	if ft == "" then ft = "plain text" end
	return wrap_hl(colors.filetype, string.format("{} %s", ft))
end

M.file_encoding = function()
	local encode = vim.bo[stbufnr()].fileencoding
	if encode == "" then encode = "none" end
	return wrap_hl(colors.gray, encode:lower())
end

M.LSP_status = function()
	local names = {}
	local clients = vim.lsp.get_clients({ bufnr = stbufnr() })
	if #clients == 0 then return "" end

	local icon = #clients > 1 and icons.ui.CheckAll or icons.ui.Check
	if vim.o.columns <= 100 then return wrap_hl(colors.green, string.format("%s %s LSPs", icon, #clients)) end

	for _, server in pairs(clients) do
		table.insert(names, server.name)
	end
	return wrap_hl(colors.green, string.format("%s %s", icon, table.concat(names, " ")))
end

M.DAP_status = function()
	local ok, dap = pcall(require, "dap")
	if not ok or not dap.session() then return "" end
	return wrap_hl(colors.debug, string.format("%s %s", icons.ui.Bug, require("dap").status()))
end

M.cwd = function()
	local cwd = vim.fn.getcwd()
	cwd = vim.fn.fnamemodify(cwd, ":t")
	if vim.o.columns <= 85 then cwd = vim.fn.pathshorten(cwd) end
	cwd = string.format("%s %s %s", (vim.fn.haslocaldir(0) == 1 and "l" or "g"), icons.documents.Folder, cwd)
	return wrap_hl(colors.directory, cwd)
end

M.hostname = function() return wrap_hl(colors.blue, string.format("%s %s", icons.ui.Laptop, vim.fn.hostname())) end

M.navic = function()
	local ok, navic = pcall(require, "nvim-navic")
	if not ok or not navic.is_available() then return "" end
	return require("nvim-navic").get_location({ highlight = false, click = true, safe_output = true })
end

M.ruler = function() return wrap_hl(colors.purple, "[%7(%l/%3L%):%2c %P]") end

M.scrollbar = function()
	local curr_line = vim.api.nvim_win_get_cursor(stwinnr())[1]
	local lines = vim.api.nvim_buf_line_count(stbufnr())
	local i = math.floor((curr_line - 1) / lines * #sbar) + 1
	return wrap_hl(colors.blue, string.rep(sbar[i], 2))
end

-- test_status = function()
-- 	return table.concat({
-- 		M.diagnostics(),
-- 	})
-- end
--
-- vim.o.statusline = "%!v:lua.test_status()"

return M
