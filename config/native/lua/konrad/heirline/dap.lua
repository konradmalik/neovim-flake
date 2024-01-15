local colors = require("konrad.heirline.colors")
local icons = require("konrad.icons")

return {
	condition = function()
		local ok, dap = pcall(require, "dap")
		if not ok then return false end
		return dap.session() ~= nil
	end,
	provider = function() return icons.ui.Bug .. " " .. require("dap").status() end,
	hl = { fg = colors.debug },
}
