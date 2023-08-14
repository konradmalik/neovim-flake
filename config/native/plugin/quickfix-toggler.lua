local qf_is_shown = function()
    return #vim.fn.filter(vim.fn.getwininfo(), 'v:val.quickfix && !v:val.loclist') > 0
end

local ll_is_shown = function()
    return #vim.fn.filter(vim.fn.getwininfo(), 'v:val.quickfix && v:val.loclist') > 0
end

local toggle_qf_list = function()
    if qf_is_shown() then
        vim.cmd("cclose")
    else
        vim.cmd("copen")
    end
end

local toggle_loc_list = function()
    if ll_is_shown() then
        vim.cmd("lclose")
    else
        if not pcall(function() vim.cmd("lopen") end) then
            vim.notify("no location list")
        end
    end
end

local opts_with_desc = function(desc, silent)
    if silent == nil then
        silent = true
    end
    local opts = { noremap = true, silent = silent }
    return vim.tbl_extend("error", opts, { desc = "[konrad] " .. desc })
end

vim.keymap.set("n", "<C-q>", toggle_qf_list, opts_with_desc("Toggle Quickfix List"))
vim.keymap.set("n", "<leader>q", toggle_loc_list, opts_with_desc("Toggle Local List"))
