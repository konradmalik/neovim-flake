local pmenu = vim.api.nvim_get_hl(0, { name = "Pmenu" })
vim.api.nvim_set_hl(0, "PmenuBorder", { bg = pmenu.bg })
vim.api.nvim_set_hl(0, "PmenuKind", { bg = pmenu.bg })

local pmenu_sel = vim.api.nvim_get_hl(0, { name = "PmenuSel" })
vim.api.nvim_set_hl(0, "PmenuKindSel", { bg = pmenu_sel.bg })
