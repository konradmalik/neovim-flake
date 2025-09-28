local cmd = require("git-conflict.commands")

require("git-conflict").setup()

local opts_with_desc = function(desc) return { desc = "[GitConflict] " .. desc } end
local function buf_opts_with_desc(bufnr, desc)
    local opts = opts_with_desc(desc)
    opts.buffer = bufnr
    return opts
end

vim.keymap.set("n", "]x", cmd.buf_next_conflict, opts_with_desc("Next Conflict"))
vim.keymap.set("n", "[x", cmd.buf_prev_conflict, opts_with_desc("Previous Conflict"))
vim.keymap.set(
    "n",
    "<leader>xq",
    cmd.send_conflicts_to_qf,
    opts_with_desc("Send repo conflicts to QF")
)

vim.api.nvim_create_autocmd("User", {
    group = vim.api.nvim_create_augroup("GitConflict", { clear = true }),
    pattern = "GitConflict",
    callback = function(args)
        local buf = args.buf

        vim.api.nvim_buf_create_user_command(
            buf,
            "ConflictChooseOurs",
            function() cmd.buf_conflict_choose_current(buf) end,
            opts_with_desc("Choose ours (current/HEAD/LOCAL)")
        )
        vim.keymap.set(
            "n",
            "<leader>co",
            function() cmd.buf_conflict_choose_current(buf) end,
            buf_opts_with_desc(buf, "Choose ours (current/HEAD/LOCAL)")
        )

        vim.api.nvim_buf_create_user_command(
            buf,
            "ConflictChooseTheirs",
            function() cmd.buf_conflict_choose_incoming(buf) end,
            opts_with_desc("Choose theirs (incoming/REMOTE)")
        )
        vim.keymap.set(
            "n",
            "<leader>ct",
            function() cmd.buf_conflict_choose_incoming(buf) end,
            buf_opts_with_desc(buf, "Choose theirs (incoming/REMOTE)")
        )

        vim.api.nvim_buf_create_user_command(
            buf,
            "ConflictChooseBoth",
            function() cmd.buf_conflict_choose_both(buf) end,
            opts_with_desc("Choose both")
        )
        vim.keymap.set(
            "n",
            "<leader>cb",
            function() cmd.buf_conflict_choose_both(buf) end,
            buf_opts_with_desc(buf, "Choose both")
        )

        vim.api.nvim_buf_create_user_command(
            buf,
            "ConflictChooseNone",
            function() cmd.buf_conflict_choose_none(buf) end,
            opts_with_desc("Choose none")
        )
        vim.keymap.set(
            "n",
            "<leader>cn",
            function() cmd.buf_conflict_choose_none(buf) end,
            buf_opts_with_desc(buf, "Choose none")
        )
    end,
})
