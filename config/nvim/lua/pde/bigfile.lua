-- https://github.com/folke/snacks.nvim/blob/main/lua/snacks/bigfile.lua
local M = {}

---@class bigfile.Config
---@field enabled? boolean
local defaults = {
    notify = true, -- show notification when big file detected
    size = 1.5 * 1024 * 1024, -- 1.5MB
}

---Enable or disable features when big file detected
---@param ctx {buf: number, ft:string}
local function set_bigfile(ctx)
    vim.cmd([[NoMatchParen]])
    vim.wo[0].foldmethod = "manual"
    vim.wo[0].statuscolumn = ""
    vim.wo[0].conceallevel = 0
    vim.schedule(function() vim.bo[ctx.buf].syntax = ctx.ft end)
end

---@param config bigfile.Config?
function M.setup(config)
    local opts = vim.tbl_deep_extend("force", defaults, config or {})

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
                        .. " Some Neovim features have been disabled.",
                    vim.log.levels.WARN
                )
            end
            vim.api.nvim_buf_call(
                ev.buf,
                function()
                    set_bigfile({
                        buf = ev.buf,
                        ft = vim.filetype.match({ buf = ev.buf }) or "",
                    })
                end
            )
        end,
    })
end

return M
