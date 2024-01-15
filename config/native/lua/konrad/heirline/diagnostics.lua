local colors = require("konrad.heirline.colors")
local conditions = require("heirline.conditions")
local icons = require("konrad.icons")
local diag_icons = icons.diagnostics

return {
	condition = conditions.has_diagnostics,

	static = {
		error_icon = diag_icons.Error,
		warn_icon = diag_icons.Warning,
		info_icon = diag_icons.Information,
		hint_icon = diag_icons.Hint,
	},

	init = function(self)
		self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
		self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
		self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
		self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
	end,

	update = { "DiagnosticChanged", "BufEnter" },
	{
		provider = function(self)
			-- 0 is just another output, we can decide to print it or not!
			return self.errors > 0 and (self.error_icon .. " " .. self.errors .. " ")
		end,
		hl = { fg = colors.diag_error },
	},
	{
		provider = function(self) return self.warnings > 0 and (self.warn_icon .. " " .. self.warnings .. " ") end,
		hl = { fg = colors.diag_warn },
	},
	{
		provider = function(self) return self.info > 0 and (self.info_icon .. " " .. self.info .. " ") end,
		hl = { fg = colors.diag_info },
	},
	{
		provider = function(self) return self.hints > 0 and (self.hint_icon .. " " .. self.hints) end,
		hl = { fg = colors.diag_hint },
	},
}
