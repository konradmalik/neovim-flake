-- we have noice at home
-- noice at home:
vim.o.cmdheight = 0
vim.api.nvim_create_autocmd({ "CmdlineEnter", "CmdlineLeave" }, {
    group = vim.api.nvim_create_augroup("cmdline-auto-hide", { clear = true }),
    callback = function(args)
        local target_height = args.event == "CmdlineEnter" and 1 or 0
        if vim.o.cmdheight ~= target_height then
            vim.o.cmdheight = target_height
            vim.cmd.redrawstatus()
        end
    end,
})
