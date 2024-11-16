local snacks = require("snacks")
snacks.setup({
    bigfile = { enabled = true },
    gitbrowse = {
        remote_patterns = {
            -- order matters
            { "^(https?://.*)%.git$", "%1" },
            { "^git@(.+):(.+)%.git$", "https://%1/%2" },
            { "^git@(.+):(.+)$", "https://%1/%2" },
            { "^git@(.+)/(.+)$", "https://%1/%2" },
            { "^ssh://git@(.*)$", "https://%1" },
            { "^ssh://([^:/]+)(:%d+)/(.*)$", "https://%1/%3" },
            { "^ssh://([^/]+)/(.*)$", "https://%1/%2" },
            { "ssh%.dev%.azure%.com/v3/(.*)/(.*)$", "dev.azure.com/%1/_git/%2" },
            { "^https://%w*@(.*)", "https://%1" },
            { "^git@(.*)", "https://%1" },
            { ":%d+", "" },
            { "%.git$", "" },
            -- custom entries
            { "repositories%.gitlab%.cerebredev", "gitlab.cerebredev" },
        },
        url_patterns = {
            ["gitlab.cerebredev.com"] = {
                branch = "/-/tree/{branch}",
                file = "/-/blob/{branch}/{file}#L{line}",
            },
        },
    },
})

local opts_with_desc = function(desc) return { desc = "[snacks] " .. desc } end

vim.keymap.set(
    "n",
    "<leader>go",
    snacks.gitbrowse.open,
    opts_with_desc("open current file in the browser")
)

vim.keymap.set("n", "grf", snacks.rename.rename_file, opts_with_desc("Rename current file"))
