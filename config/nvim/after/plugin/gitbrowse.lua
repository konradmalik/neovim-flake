-- it's in after to replace fugitive
local gitbrowse = require("pde.gitbrowse")
gitbrowse.setup(function(opts)
    table.insert(opts.remote_patterns, { "repositories%.gitlab", "gitlab" })
    opts.url_patterns["gitlab%.cerebredev%.com"] = opts.url_patterns["gitlab%.com"]
end)

vim.api.nvim_create_user_command(
    "GBrowse",
    function(params) gitbrowse.open({ line_start = params.line1, line_end = params.line2 }) end,
    { desc = "[gitbrowse] open current file in the browser", range = true }
)
