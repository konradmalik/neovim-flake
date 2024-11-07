--NOTE stolen from https://github.com/folke/snacks.nvim/blob/main/lua/snacks/bigfile.lua

---@private
---@class pde.bigfile
local M = {}

---@class pde.bigfile.Config
local defaults = {
    notify = true, -- show notification when big file detected
    size = 1.5 * 1024 * 1024, -- 1.5MB
    -- Enable or disable features when big file detected
    ---@param ctx {buf: number, ft:string}
    setup = function(ctx)
        vim.b.minianimate_disable = true
        vim.schedule(function() vim.bo[ctx.buf].syntax = ctx.ft end)
    end,
}

---@param opts pde.bigfile.Config?
function M.setup(opts)
    opts = vim.tbl_deep_extend("force", defaults, opts or {})

    vim.filetype.add({
        pattern = {
            [".*"] = {
                function(path, buf)
                    return vim.bo[buf]
                            and vim.bo[buf].filetype ~= "bigfile"
                            and path
                            and vim.fn.getfsize(path) > opts.size
                            and "bigfile"
                        or nil
                end,
            },
        },
    })

    vim.api.nvim_create_autocmd({ "FileType" }, {
        group = vim.api.nvim_create_augroup("pde_bigfile", { clear = true }),
        pattern = "bigfile",
        callback = function(ev)
            if opts.notify then
                local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(ev.buf), ":p:~:.")
                vim.notify(
                    ("Big file detected `%s`."):format(path)
                        .. " Some Neovim features have been **disabled**.",
                    vim.log.levels.WARN,
                    { title = "Big File" }
                )
            end
            vim.api.nvim_buf_call(
                ev.buf,
                function()
                    opts.setup({
                        buf = ev.buf,
                        ft = vim.filetype.match({ buf = ev.buf }) or "",
                    })
                end
            )
        end,
    })
end

return M
