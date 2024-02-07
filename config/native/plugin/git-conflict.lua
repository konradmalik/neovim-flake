local cmd = require("git-conflict.commands")
local gc = require("git-conflict")
local opts_with_desc = function(desc) return { desc = "[GitConflict] " .. desc } end
local function buf_opts_with_desc(bufnr, desc)
    local opts = opts_with_desc(desc)
    opts.buffer = bufnr
    return opts
end

gc.setup({
    highlights = {
        current = "diffAdded",
        incoming = "diffChanged",
        ancestor = "diffDeleted",
    },
})

local group = vim.api.nvim_create_augroup("GitConflict", { clear = true })

vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
    group = group,
    callback = function(args)
        local buf = args.buf
        gc.refresh(buf)
    end,
})

vim.keymap.set("n", "]x", cmd.buf_next_conflict, opts_with_desc("Next Conflict"))
vim.keymap.set("n", "[x", cmd.buf_prev_conflict, opts_with_desc("Previous Conflict"))
vim.keymap.set(
    "n",
    "<leader>xq",
    cmd.send_conflicts_to_qf,
    opts_with_desc("Send repo conflicts to QF")
)

vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "GitConflict",
    callback = function(args)
        local buf = args.buf

        vim.keymap.set(
            "n",
            "<leader>co",
            function() cmd.buf_conflict_choose_current(buf) end,
            buf_opts_with_desc(buf, "Choose ours (current/HEAD/LOCAL)")
        )

        vim.keymap.set(
            "n",
            "<leader>ct",
            function() cmd.buf_conflict_choose_incoming(buf) end,
            buf_opts_with_desc(buf, "Choose theirs (incoming/REMOTE)")
        )

        vim.keymap.set(
            "n",
            "<leader>cb",
            function() cmd.buf_conflict_choose_both(buf) end,
            buf_opts_with_desc(buf, "Choose both")
        )

        vim.keymap.set(
            "n",
            "<leader>cn",
            function() cmd.buf_conflict_choose_none(buf) end,
            buf_opts_with_desc(buf, "Choose none")
        )
    end,
})