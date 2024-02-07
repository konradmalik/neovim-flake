local M = {}

---@class featureOpts
---@field defer boolean|nil If true the feature will be disabled in vim.schedule

---@class feature
---@field disable function Disables the feature
---@field opts featureOpts

---@type feature
M.lsp = {
    disable = function(buf)
        vim.api.nvim_create_autocmd({ "LspAttach" }, {
            buffer = buf,
            callback = function(args)
                vim.schedule(function() vim.lsp.buf_detach_client(buf, args.data.client_id) end)
            end,
        })
    end,
    opts = {},
}

---@type feature
M.treesitter = {
    disable = function(buf) vim.treesitter.stop(buf) end,
    opts = {},
}

---@type feature
M.vimopts = {
    disable = function()
        vim.opt_local.swapfile = false
        vim.opt_local.foldmethod = "manual"
        vim.opt_local.undolevels = -1
        vim.opt_local.undoreload = 0
        vim.opt_local.list = false
    end,
    opts = {},
}

---@type feature
M.syntax = {
    opts = { defer = true },
    disable = function()
        vim.cmd("syntax clear")
        vim.opt_local.syntax = "OFF"
    end,
}

---@type feature
M.filetype = {
    opts = { defer = true },
    disable = function() vim.opt_local.filetype = "" end,
}

return M
