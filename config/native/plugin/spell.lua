local paths = require("pde.paths")

local lang = "en"
local spellfile = paths.get_spellfile(lang)
vim.opt.spelllang = { lang }
vim.opt.spellfile = spellfile
vim.opt.spell = true

vim.api.nvim_create_user_command("MkSpell", function()
    local path = paths.get_spellfile(nil)
    local entries = vim.fn.split(vim.fn.glob(path .. "/*.add"), "\n")
    for _, entry in pairs(entries) do
        vim.cmd.mkspell({ entry, bang = true })
    end
end, {
    desc = "Regenerates spellfiles for all languages",
})
