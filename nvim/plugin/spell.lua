local paths = require("pde.paths")

local lang = "en"
local spellfile = paths.get_spellfile(lang)
vim.opt.spelllang = { lang }
vim.o.spellfile = spellfile
vim.o.spell = true
-- split camelCase words and skip buffers without syntax/treesitter spell info
vim.opt.spelloptions = { "camel", "noplainbuffer" }
-- sentence capitalization is too noisy
vim.o.spellcapcheck = ""

vim.api.nvim_create_user_command("MkSpell", function()
    local path = paths.get_spellfile(nil)
    local entries = vim.fn.split(vim.fn.glob(path .. "/*.add"), "\n")
    for _, entry in pairs(entries) do
        vim.cmd.mkspell({ entry, bang = true })
    end
end, {
    desc = "Regenerates spellfiles for all languages",
})
