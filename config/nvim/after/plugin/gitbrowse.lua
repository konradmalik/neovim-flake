-- it's in after to replace fugitive
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

vim.api.nvim_create_user_command("GBrowse", function(params)
    local opts =
        vim.tbl_extend("force", config, { line_start = params.line1, line_end = params.line2 })
    gitbrowse.open(opts)
end, { desc = "[gitbrowse] open current file in the browser", range = true })
