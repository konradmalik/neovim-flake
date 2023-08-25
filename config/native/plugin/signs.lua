local icons = require("konrad.icons")
local diag_icons = icons.diagnostics
local signs = {
    { name = "DiagnosticSignError", text = diag_icons.Error,       texthl = "DiagnosticSignError" },
    { name = "DiagnosticSignWarn",  text = diag_icons.Warning,     texthl = "DiagnosticSignWarn" },
    { name = "DiagnosticSignInfo",  text = diag_icons.Information, texthl = "DiagnosticSignInfo" },
    { name = "DiagnosticSignHint",  text = diag_icons.Hint,        texthl = "DiagnosticSignHint" },
}

for _, sign in ipairs(signs) do
    vim.fn.sign_define(sign.name, sign)
end
