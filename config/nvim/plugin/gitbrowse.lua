local gitbrowse = require("pde.gitbrowse")
local config = {
    config = function(opts, _)
        table.insert(
            opts.remote_patterns,
            { "repositories%.gitlab%.cerebredev", "gitlab.cerebredev" }
        )
        opts.url_patterns["gitlab%.cerebredev%.com"] = opts.url_patterns["gitlab%.com"]
    end,
}

local opts_with_desc = function(desc) return { desc = "[gitbrowse] " .. desc } end

vim.keymap.set(
    { "n", "v" },
    "<leader>gof",
    function() gitbrowse.open(config) end,
    opts_with_desc("open current file in the browser")
)
