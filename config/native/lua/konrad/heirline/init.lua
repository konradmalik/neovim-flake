local heirline = require("heirline")

local colors = require("konrad.heirline.colors")

local conditions = require("heirline.conditions")
local icons = require("konrad.icons")
local utils = require("heirline.utils")

local Align = require("konrad.heirline.primitives").Align
local Space = require("konrad.heirline.primitives").Space

local ViMode = require("konrad.heirline.vimode")
ViMode = utils.surround({ icons.ui.LeftHalf, icons.ui.RightHalf }, colors.bright_bg, { ViMode })
local FileNameBlock = require("konrad.heirline.filename").FileNameBlock
local FileName = require("konrad.heirline.filename").FileNameFlexible
local HelpFileName = require("konrad.heirline.filename").HelpFileName
local TerminalName = require("konrad.heirline.terminal").TerminalName
local Diagnostics = require("konrad.heirline.diagnostics")
local Git = require("konrad.heirline.git")
local Navic = require("konrad.heirline.navic").NavicFlexible
local DAPMessages = require("konrad.heirline.dap")
local LSPActive = require("konrad.heirline.lsp").LSPActive
local FileType = require("konrad.heirline.fileutils").FileType
local FileEncoding = require("konrad.heirline.fileutils").FileEncoding
local FileFormat = require("konrad.heirline.fileutils").FileFormat
local Hostname = require("konrad.heirline.hostname")
local Ruler = require("konrad.heirline.ruler")
local ScrollBar = require("konrad.heirline.scrollbar")

local InactiveWinbar = {
	condition = function() return not conditions.is_active() end,
	utils.surround(
		{ icons.ui.LeftHalf, icons.ui.RightHalf },
		colors.bright_bg,
		{ hl = { fg = colors.gray, force = true }, FileNameBlock }
	),
}

local TerminalWinbar = {
	-- A special winbar for terminals
	condition = function() return conditions.buffer_matches({ buftype = { "terminal" } }) end,
	utils.surround({ icons.ui.LeftHalf, icons.ui.RightHalf }, colors.dark_red, {
		FileType,
		Space,
		TerminalName,
	}),
}

local DefaultWinbar = {
	FileNameBlock,
	Space,
	Navic,
	Align,
}

local Winbars = {
	fallthrough = false,
	InactiveWinbar,
	TerminalWinbar,
	DefaultWinbar,
}

local DefaultStatusline = {
	ViMode,
	Space,
	Git,
	Align,
	DAPMessages,
	Align,
	Diagnostics,
	Space,
	LSPActive,
	Space,
	FileType,
	Space,
	FileFormat,
	Space,
	FileEncoding,
	Space,
	Hostname,
	Space,
	Ruler,
	Space,
	ScrollBar,
}

local InactiveStatusline = {
	condition = conditions.is_not_active,
	FileType,
	Space,
	FileName,
	Align,
}

local TerminalStatusline = {
	condition = function() return conditions.buffer_matches({ buftype = { "terminal" } }) end,

	hl = { bg = colors.dark_red },

	-- Quickly add a condition to the ViMode to only show it when buffer is active!
	{ condition = conditions.is_active, ViMode, Space },
	FileType,
	Space,
	TerminalName,
	Align,
}

local defaultConfig = {
	specialBufferMatches = {
		buftype = { "nofile", "prompt", "help", "quickfix" },
		filetype = { "^git.*", "fugitive", "harpoon", "undotree", "diff" },
	},
}

local M = {}

M.setup = function(config)
	local mergedConfig = vim.tbl_deep_extend("force", defaultConfig, config)

	-- global statusline
	vim.o.laststatus = 3

	local SpecialStatusline = {
		condition = function() return conditions.buffer_matches(mergedConfig.specialBufferMatches) end,
		FileType,
		Space,
		HelpFileName,
		Align,
	}

	local StatusLines = {
		hl = function()
			if conditions.is_active() then
				return "StatusLine"
			else
				return "StatusLineNC"
			end
		end,
		-- the first statusline with no condition, or which condition returns true is used.
		-- think of it as a switch case with breaks to stop fallthrough.
		fallthrough = false,
		SpecialStatusline,
		TerminalStatusline,
		InactiveStatusline,
		DefaultStatusline,
	}

	heirline.setup({
		winbar = Winbars,
		statusline = StatusLines,
		opts = {
			colors = colors,
			-- if the callback returns true, the winbar will be disabled for that window
			-- the args parameter corresponds to the table argument passed to autocommand callbacks. :h nvim_lua_create_autocmd()
			disable_winbar_cb = function(args)
				return conditions.buffer_matches(mergedConfig.specialBufferMatches, args.buf)
			end,
		},
	})
end

return M
