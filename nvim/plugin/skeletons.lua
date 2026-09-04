local skeletons_path = vim.api.nvim_get_runtime_file("skeletons", false)[1]
if not skeletons_path then return end

local group = vim.api.nvim_create_augroup("personal-skeletons", { clear = true })

local insert_skeleton = function(name)
    vim.cmd.read({ vim.fn.fnameescape(vim.fs.joinpath(skeletons_path, name)), range = { 0 } })
end

for name, _ in vim.fs.dir(skeletons_path) do
    vim.api.nvim_create_autocmd({ "BufNewFile" }, {
        group = group,
        pattern = name,
        callback = function() insert_skeleton(name) end,
    })
end
