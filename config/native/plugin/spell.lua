local spellfile_path = function()
    local repo = vim.uv.os_homedir() .. "/Code/github.com/konradmalik/neovim-flake"
    if vim.fn.isdirectory(repo) == 0 then
        return vim.fn.stdpath("config") .. "/spell/en.utf-8.add"
    end

    return repo .. "/files/spell/en.utf-8.add"
end

vim.opt.spelllang = { "en_us" }
vim.opt.spell = true
vim.opt.spellfile = spellfile_path()

vim.api.nvim_create_user_command(
    "MkSpell",
    function() vim.cmd("mkspell! " .. spellfile_path()) end,
    {
        desc = "Regenerates spellfile for " .. spellfile_path(),
    }
)
