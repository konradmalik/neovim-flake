local conflicts = {}
local gather_stdout = function(_, data, _)
    for _, entry in ipairs(data) do
        if entry and entry ~= "" then
            table.insert(conflicts, entry)
        end
    end
end

local stdout_to_qflist = function()
    local qf_entries = {}
    for _, conflict in ipairs(conflicts) do
        local filename, line, col, text = conflict:match("(.+):(%d+):(%d?) (.+)")
        table.insert(qf_entries, {
            filename = filename,
            lnum = line,
            col = col,
            text = text,
            type = "E",
        })
    end
    vim.fn.setqflist({}, "r", { title = "Git Conflicts", items = qf_entries })
end

local start_conflicts_job = function()
    return vim.fn.jobstart({ "git", "--no-pager", "diff", "--no-color", "--check", "--relative" }, {
        on_stdout = gather_stdout,
        on_exit = stdout_to_qflist,
    })
end

local M = {}

M.setqflist = function()
    start_conflicts_job()
end

return M
