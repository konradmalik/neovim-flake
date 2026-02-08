local icons = require("pde.statusline.icons")
local mini_icons = require("mini.icons")
local utils = require("pde.statusline.utils")

---@param hl string highlight name
---@param s string string to wrap
---@return string
local function wrap_hl(hl, s) return "%#" .. hl .. "#" .. s .. "%*" end

---@param func_name string name of lua function in this module
---@param s string string to wrap
---@return string
local function wrap_click(func_name, s)
    return "%@v:lua.require'pde.statusline.components'." .. func_name .. "@" .. s .. "%X"
end

local colors = {
    string = "String",
    func = "Function",
    nontext = "NonText",
    constant = "Constant",
    statement = "Statement",
    special = "Special",
    diag_warn = "DiagnosticWarn",
    diag_error = "DiagnosticError",
    diag_hint = "DiagnosticHint",
    diag_info = "DiagnosticInfo",
    diag_ok = "DiagnosticOk",
    git_del = "diffDeleted",
    git_add = "diffAdded",
    git_change = "diffChanged",
    directory = "Directory",
    filetype = "Type",
    text = "Normal",
    debug = "Debug",
}

local sbar = icons.ui.Animations.Fill

local format_types = {
    unix = icons.oss.Linux,
    mac = icons.oss.Mac,
    dos = icons.oss.Windows,
}

local modes = {
    ["n"] = { "N", colors.func },
    ["no"] = { "N?", colors.func },
    ["nov"] = { "N?", colors.func },
    ["noV"] = { "N?", colors.func },
    ["no\22"] = { "N?", colors.func },
    ["niI"] = { "Ni", colors.func },
    ["niR"] = { "Nr", colors.func },
    ["niV"] = { "Nv", colors.func },
    ["nt"] = { "Nt", colors.func },
    ["ntT"] = { "Nt", colors.func },

    ["v"] = { "V", colors.special },
    ["vs"] = { "Vs", colors.special },
    ["V"] = { "V_", colors.special },
    ["Vs"] = { "Vs", colors.special },
    [""] = { "^V", colors.special },
    ["s"] = { "^V", colors.special },

    ["s"] = { "S", colors.statement },
    ["S"] = { "S_", colors.statement },
    [""] = { "^S", colors.statement },

    ["i"] = { "I", colors.string },
    ["ic"] = { "Ic", colors.string },
    ["ix"] = { "Ix", colors.string },

    ["R"] = { "R", colors.constant },
    ["Rc"] = { "Rc", colors.constant },
    ["Rx"] = { "Rx", colors.constant },
    ["Rv"] = { "Rv", colors.constant },
    ["Rvc"] = { "Rv", colors.constant },
    ["Rvx"] = { "Rv", colors.constant },

    ["c"] = { "c", colors.constant },
    ["cv"] = { "Ex", colors.constant },
    ["ce"] = { "Ex", colors.constant },
    ["r"] = { "...", colors.constant },
    ["rm"] = { "M", colors.constant },
    ["r?"] = { "?", colors.constant },
    ["!"] = { "!", colors.constant },

    ["x"] = { "X", colors.statement },

    ["t"] = { "T", colors.func },
}

local M = {}

M.space = " "

M.align = "%="

M.cut = "%<"

M.busy = function()
    local busy = vim.bo[utils.stbufnr()].busy
    if busy == 0 then return "" end
    return wrap_hl(colors.statement, "<buffer is busy>")
end

M.mode = function()
    local m = modes[vim.api.nvim_get_mode().mode]

    local mname = m[1]
    local mhl = m[2]
    local hl = vim.api.nvim_get_hl(0, { name = mhl })

    local left = wrap_hl(mhl, icons.ui.LeftHalf)
    local right = wrap_hl(mhl, icons.ui.RightHalf)

    vim.api.nvim_set_hl(0, "StMode", { bold = true, bg = hl.fg, fg = "bg" })
    local mode = wrap_hl("StMode", icons.misc.Neovim .. " " .. mname)

    return left .. mode .. right
end

M.fileinfo = function(active)
    local bufnr = utils.stbufnr()
    local bufname = vim.api.nvim_buf_get_name(bufnr)

    local icon, ihl, _ = mini_icons.get("file", bufname)
    local hl
    if not active then
        ihl = colors.nontext
        hl = colors.nontext
    else
        hl = colors.text
    end

    local filename
    if bufname == "" then
        filename = "[No Name]"
    else
        filename = vim.fn.fnamemodify(bufname, ":.") or ""
    end
    local text = wrap_hl(ihl, icon) .. " " .. wrap_hl(hl, filename)

    if vim.bo[bufnr].modified then return text .. wrap_hl(colors.diag_ok, " " .. icons.git.Mod) end

    if vim.bo[bufnr].readonly then
        text = text .. wrap_hl(colors.diag_warn, " " .. icons.ui.Lock)
    end
    if not vim.bo[bufnr].modifiable then
        text = text .. wrap_hl(colors.diag_error, " " .. icons.ui.FilledLock)
    end

    return text
end

M.fileformat = function()
    return wrap_hl(colors.nontext, format_types[vim.bo[utils.stbufnr()].fileformat])
end

M.git = function()
    local head = vim.b[utils.stbufnr()].gitsigns_head
    if not head then return "" end
    return wrap_click("git_click", wrap_hl(colors.constant, icons.git.Branch .. " " .. head))
end

M.gitchanges = function()
    local git_status = vim.b[utils.stbufnr()].gitsigns_status_dict
    if not git_status then return "" end

    local added = (git_status.added and git_status.added ~= 0)
            and wrap_hl(colors.git_add, icons.git.Add .. " " .. git_status.added .. " ")
        or ""
    local changed = (git_status.changed and git_status.changed ~= 0)
            and wrap_hl(colors.git_change, icons.git.Mod .. " " .. git_status.changed .. " ")
        or ""
    local removed = (git_status.removed and git_status.removed ~= 0)
            and wrap_hl(colors.git_del, icons.git.Remove .. " " .. git_status.removed .. " ")
        or ""

    return wrap_click("git_click", added .. changed .. removed)
end

M.git_click = function() vim.cmd("Git") end

M.diagnostics = function()
    if not vim.diagnostic.is_enabled({ bufnr = utils.stbufnr() }) then return "" end
    return vim.diagnostic.status(utils.stbufnr())
end

M.filetype = function()
    local ft = vim.bo[utils.stbufnr()].filetype
    if ft == "" then ft = "plain text" end
    return wrap_hl(colors.filetype, icons.documents.FileContents .. " " .. ft)
end

M.file_encoding = function()
    local encode = vim.bo[utils.stbufnr()].fileencoding
    if encode == "" then encode = "none" end
    return wrap_hl(colors.nontext, encode:lower())
end

M.LSP_status = function()
    local clients = vim.lsp.get_clients({ bufnr = utils.stbufnr() })
    local numClients = #clients
    if numClients == 0 then return "" end

    local icon = numClients > 1 and icons.ui.HexagonAll or icons.ui.Hexagon
    local text
    if numClients >= 3 then
        text = icon .. " " .. numClients .. " LSPs"
    else
        local texts = { icon }
        for _, server in pairs(clients) do
            table.insert(texts, server.name)
        end
        text = table.concat(texts, " ")
    end
    return wrap_click("LSP_click", wrap_hl(colors.string, text))
end

M.LSP_click = function() vim.cmd("checkhealth lsp") end

M.cwd = function()
    local winnr = utils.stwinnr()
    local cwd = vim.fn.getcwd(winnr)
    cwd = vim.fn.fnamemodify(cwd, ":t")
    cwd = (vim.fn.haslocaldir(winnr) == 1 and "l" or "g")
        .. " "
        .. icons.documents.Folder
        .. " "
        .. cwd
    return wrap_hl(colors.directory, cwd)
end

do
    local hostname
    M.hostname = function()
        if not hostname then
            hostname = wrap_hl(colors.func, icons.ui.Terminal .. " " .. vim.fn.hostname())
        end
        return hostname
    end
end

do
    local ruler
    M.ruler = function()
        if not ruler then ruler = wrap_hl(colors.statement, "[%7(%l/%3L%):%2c %P]") end
        return ruler
    end
end

M.scrollbar = function()
    local curr_line = vim.api.nvim_win_get_cursor(utils.stwinnr())[1]
    local lines = vim.api.nvim_buf_line_count(utils.stbufnr())
    if lines == 0 then return sbar[1] end
    local i = math.floor((curr_line - 1) / lines * #sbar) + 1
    return wrap_hl(colors.func, sbar[i])
end

-- test_status = function()
-- 	return table.concat({
-- 		M.diagnostics(),
-- 	})
-- end
--
-- vim.o.statusline = "%!v:lua.test_status()"

return M
