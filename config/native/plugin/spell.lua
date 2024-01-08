local spellfile_path = vim.uv.os_homedir() .. "/Code/github.com/konradmalik/neovim-flake/files/en.utf-8.add"

vim.opt.spelllang = { "en_us" }
vim.opt.spell = true
vim.opt.spellfile = spellfile_path

vim.api.nvim_create_user_command("MkSpell", function()
    vim.cmd("mkspell! " .. spellfile_path)
end, {
    desc = "Regenerates spellfile from " .. spellfile_path,
})
