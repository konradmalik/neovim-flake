-- https://github.com/folke/snacks.nvim/blob/main/lua/snacks/bigfile.lua
local M = {}

---@class bigfile.Config
---@field enabled? boolean
local defaults = {
    notify = true, -- show notification when big file detected
    size = 1.5 * 1024 * 1024, -- 1.5MB
    line_length = 1000, -- average line length (useful for minified files)
}

---Enable or disable features when big file detected
---@param ctx {buf: number, ft:string}
local function set_bigfile(ctx)
    if vim.fn.exists(":NoMatchParen") ~= 0 then vim.cmd([[NoMatchParen]]) end
    vim.bo.autocomplete = false
    vim.wo[0].foldmethod = "manual"
    vim.wo[0].statuscolumn = ""
    vim.wo[0].conceallevel = 0
    vim.schedule(function()
        if vim.api.nvim_buf_is_valid(ctx.buf) then vim.bo[ctx.buf].syntax = ctx.ft end
    end)
end

---@param config bigfile.Config?
function M.setup(config)
    local opts = vim.tbl_deep_extend("force", defaults, config or {})

    vim.filetype.add({
        pattern = {
            [".*"] = {
                function(path, buf)
                    if not path or not buf or vim.bo[buf].filetype == "bigfile" then return end
                    if path ~= vim.api.nvim_buf_get_name(buf) then return end

                    local size = vim.fn.getfsize(path)
                    if size <= 0 then return end
                    if size > opts.size then return "bigfile" end

                    local lines = vim.api.nvim_buf_line_count(buf)
                    return (size - lines) / lines > opts.line_length and "bigfile" or nil
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
