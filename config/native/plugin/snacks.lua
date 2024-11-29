local snacks = require("snacks")
snacks.setup({
    bigfile = { enabled = true },
    gitbrowse = {
        config = function(opts, _)
            table.insert(
                opts.remote_patterns,
                { "repositories%.gitlab%.cerebredev", "gitlab.cerebredev" }
            )
            opts.url_patterns["gitlab.cerebredev.com"] = {
                branch = "/-/tree/{branch}",
                file = "/-/blob/{branch}/{file}#L{line}",
            }
        end,
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
