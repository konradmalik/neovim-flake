--- @class CSharpConfig
--- @field lsp string
local current_config = {
    lsp = "omnisharp",
}

local M = {}

---@param config CSharpConfig
M.setup = function(config)
    current_config = vim.tbl_deep_extend("force", current_config, config)
end

M.current_config = function()
    return current_config
end

return M
