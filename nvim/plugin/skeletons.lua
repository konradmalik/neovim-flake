local current_file_path = vim.fs.dirname(debug.getinfo(1, "S").source:sub(2))
local skeletons_path = vim.fs.normalize(current_file_path .. "/../skeletons")

local group = vim.api.nvim_create_augroup("personal-skeletons", { clear = true })

local insert_skeleton = function(name) vim.cmd("0r " .. vim.fs.joinpath(skeletons_path, name)) end

vim.api.nvim_create_autocmd({ "BufNewFile" }, {
    group = group,
    pattern = ".tmux.sh",
    callback = function() insert_skeleton(".tmux.sh") end,
})

vim.api.nvim_create_autocmd({ "BufNewFile" }, {
    group = group,
    pattern = ".editorconfig",
    callback = function() insert_skeleton(".editorconfig") end,
})
