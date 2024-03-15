local system = require("konrad.system")

local lang = "en"
local spellfile = system.spellfile_path(lang)
vim.opt.spelllang = { lang }
vim.opt.spellfile = spellfile
vim.opt.spell = true

vim.api.nvim_create_user_command("MkSpell", function()
    local path = system.spellfile_path(nil)
    local entries = vim.fn.split(vim.fn.glob(path .. "/*.add"), "\n")
    for _, entry in pairs(entries) do
        vim.cmd("mkspell! " .. entry)
    end
end, {
    desc = "Regenerates spellfiles for all languages",
})
