local components = require("pde.statusline.components")

---@type fun(): integer
local function stwinnr() return vim.g.statusline_winid end

---@type fun(): integer
local function stbufnr() return vim.api.nvim_win_get_buf(stwinnr()) end

--- Check if the provided winid is the active one
---@param winid integer
---@return boolean
local function is_activewin(winid) return vim.api.nvim_get_current_win() == winid end

---@param bufnr integer
---@return boolean
local function is_special(bufnr) return vim.bo[bufnr].buftype ~= "" end

local function setup_statusline()
    vim.g.qf_disable_statusline = true
    vim.o.laststatus = 3
    -- highlight group of the active window statusline
    vim.api.nvim_set_hl(0, "StatusLine", { bg = "bg", fg = "fg" })
    -- nc -> non-active
    vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "bg", fg = "fg" })

    vim.o.statusline = "%!v:lua.require('pde.statusline').statusline()"
end
local function setup_local_winbar_with_autocmd()
    local winbar = "%!v:lua.require('pde.statusline').winbar()"
    local group = vim.api.nvim_create_augroup("personal-winbar", { clear = true })
    vim.api.nvim_create_autocmd({ "VimEnter", "UIEnter", "BufWinEnter", "FileType", "TermOpen" }, {
        group = group,
        callback = function(event)
            for _, winid in ipairs(vim.api.nvim_list_wins()) do
                local winbuf = vim.api.nvim_win_get_buf(winid)

                if event.event == "VimEnter" or event.event == "UIEnter" or winbuf == event.buf then
                    if is_special(winbuf) then
                        if vim.wo[winid][0].winbar == winbar then vim.wo[winid][0].winbar = nil end
                    else
                        vim.wo[winid][0].winbar = winbar
                    end
                end
            end
        end,
        desc = "Personal: set window-local winbar",
    })

    -- fix fugitive windows scroll-sync by placing a dummy winbar in them
    vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = { "fugitiveblame" },
        callback = function() vim.wo[0][0].winbar = "Fugitive" end,
        desc = "Personal: fix fugitive alignment",
    })
end

local M = {}

M.statusline = function()
    local bufnr = stbufnr()
    if is_special(bufnr) then return components.filetype(bufnr) .. components.busy(bufnr) end

    return components.mode()
        .. components.space
        .. components.space
        .. components.git(bufnr)
        .. components.space
        .. components.gitchanges(bufnr)
        .. components.cut
        .. components.align
        .. components.busy(bufnr)
        .. components.align
        .. components.diagnostics(bufnr)
        .. components.space
        .. components.space
        .. components.LSP_status(bufnr)
        .. components.space
        .. components.filetype(bufnr)
        .. components.space
        .. components.fileformat(bufnr)
        .. components.space
        .. components.file_encoding(bufnr)
        .. components.space
        .. components.ruler()
end

M.winbar = function()
    local bufnr = stbufnr()
    local winid = stwinnr()
    if not is_activewin(winid) then return components.cut .. components.fileinfo(bufnr, false) end

    return components.cut
        .. components.cwd(winid)
        .. components.space
        .. components.fileinfo(bufnr, true)
end

M.setup = function()
    setup_statusline()
    setup_local_winbar_with_autocmd()
end

return M
