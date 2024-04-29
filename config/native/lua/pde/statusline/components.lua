local devicons = require("nvim-web-devicons")
local icons = require("pde.icons")
local utils = require("pde.statusline.utils")

---@param hl string
---@param s string
---@return string
local function wrap_hl(hl, s) return "%#" .. hl .. "#" .. s .. "%*" end

local colors = {
    green = "String",
    blue = "Function",
    gray = "NonText",
    orange = "Constant",
    purple = "Statement",
    cyan = "Special",
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

local sbar = icons.ui.Animations.ThinFill

local format_types = {
    unix = icons.oss.Linux,
    mac = icons.oss.Mac,
    dos = icons.oss.Windows,
}

local modes = {
    ["n"] = { "N", colors.blue },
    ["no"] = { "N?", colors.blue },
    ["nov"] = { "N?", colors.blue },
    ["noV"] = { "N?", colors.blue },
    ["no\22"] = { "N?", colors.blue },
    ["niI"] = { "Ni", colors.blue },
    ["niR"] = { "Nr", colors.blue },
    ["niV"] = { "Nv", colors.blue },
    ["nt"] = { "Nt", colors.blue },
    ["ntT"] = { "Nt", colors.blue },

    ["v"] = { "V", colors.cyan },
    ["vs"] = { "Vs", colors.cyan },
    ["V"] = { "V_", colors.cyan },
    ["Vs"] = { "Vs", colors.cyan },
    [""] = { "^V", colors.cyan },
    ["s"] = { "^V", colors.cyan },

    ["s"] = { "S", colors.purple },
    ["S"] = { "S_", colors.purple },
    [""] = { "^S", colors.purple },

    ["i"] = { "I", colors.green },
    ["ic"] = { "Ic", colors.green },
    ["ix"] = { "Ix", colors.green },

    ["R"] = { "R", colors.orange },
    ["Rc"] = { "Rc", colors.orange },
    ["Rx"] = { "Rx", colors.orange },
    ["Rv"] = { "Rv", colors.orange },
    ["Rvc"] = { "Rv", colors.orange },
    ["Rvx"] = { "Rv", colors.orange },

    ["c"] = { "c", colors.orange },
    ["cv"] = { "Ex", colors.orange },
    ["ce"] = { "Ex", colors.orange },
    ["r"] = { "...", colors.orange },
    ["rm"] = { "M", colors.orange },
    ["r?"] = { "?", colors.orange },
    ["!"] = { "!", colors.orange },

    ["x"] = { "X", colors.purple },

    ["t"] = { "T", colors.blue },
}

local M = {}

M.space = " "

M.align = "%="

M.cut = "%<"

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

    local filename
    local extension
    if bufname == "" then
        filename = "[No Name]"
        extension = ""
    else
        filename = vim.fn.fnamemodify(bufname, ":.") or ""
        extension = vim.fn.fnamemodify(bufname, ":e") or ""
    end

    local icon, color = devicons.get_icon_color(bufname, extension, { default = true })

    local ihl
    local hl
    if not active then
        ihl = colors.gray
        hl = colors.gray
    else
        ihl = "StFileInfo"
        vim.api.nvim_set_hl(0, ihl, { fg = color })
        hl = colors.text
    end

    local text = wrap_hl(ihl, icon) .. " " .. wrap_hl(hl, filename)

    if vim.bo[bufnr].modified then return text .. wrap_hl(colors.diag_ok, icons.ui.Square) end

    if vim.bo[bufnr].readonly then text = text .. wrap_hl(colors.diag_warn, icons.ui.Lock) end
    if not vim.bo[bufnr].modifiable then
        text = text .. wrap_hl(colors.diag_error, icons.ui.FilledLock)
    end

    return text
end

M.fileformat = function()
    return wrap_hl(colors.gray, format_types[vim.bo[utils.stbufnr()].fileformat])
end

M.git = function()
    local head = vim.b[utils.stbufnr()].gitsigns_head
    if not head then return "" end
    return wrap_hl(colors.orange, icons.git.Branch .. " " .. head)
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

    return added .. changed .. removed
end

M.diagnostics = function()
    local counts = vim.diagnostic.count(utils.stbufnr())
    local numErrors = counts[vim.diagnostic.severity.ERROR] or 0
    local numWarnings = counts[vim.diagnostic.severity.WARN] or 0
    local numHints = counts[vim.diagnostic.severity.HINT] or 0
    local numInfo = counts[vim.diagnostic.severity.INFO] or 0

    local errors = wrap_hl(colors.diag_error, icons.diagnostics.Error .. " " .. numErrors .. " ")
    local warnings =
        wrap_hl(colors.diag_warn, icons.diagnostics.Warning .. " " .. numWarnings .. " ")
    local hints = wrap_hl(colors.diag_hint, icons.diagnostics.Hint .. " " .. numHints .. " ")
    local info = wrap_hl(colors.diag_info, icons.diagnostics.Information .. " " .. numInfo .. " ")

    errors = numErrors > 0 and errors or ""
    warnings = numWarnings > 0 and warnings or ""
    hints = numHints > 0 and hints or ""
    info = numInfo > 0 and info or ""

    return errors .. warnings .. hints .. info
end

M.filetype = function()
    local ft = vim.bo[utils.stbufnr()].filetype
    if ft == "" then ft = "plain text" end
    return wrap_hl(colors.filetype, icons.documents.FileContents .. " " .. ft)
end

M.file_encoding = function()
    local encode = vim.bo[utils.stbufnr()].fileencoding
    if encode == "" then encode = "none" end
    return wrap_hl(colors.gray, encode:lower())
end

M.LSP_status = function()
    local clients = vim.lsp.get_clients({ bufnr = utils.stbufnr() })
    local numClients = #clients
    if numClients == 0 then return "" end

    local icon = numClients > 1 and icons.ui.CheckAll or icons.ui.Check
    if numClients >= 3 then return wrap_hl(colors.green, icon .. " " .. numClients .. " LSPs") end

    local texts = { icon }
    for _, server in pairs(clients) do
        table.insert(texts, server.name)
    end
    return wrap_hl(colors.green, table.concat(texts, " "))
end

M.DAP_status = function()
    local ok, dap = pcall(require, "dap")
    if not ok or not dap.session() then return "" end
    return wrap_hl(colors.debug, icons.ui.Bug .. " " .. dap.status())
end

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
            hostname = wrap_hl(colors.blue, icons.ui.Laptop .. " " .. vim.fn.hostname())
        end
        return hostname
    end
end

do
    local ruler
    M.ruler = function()
        if not ruler then ruler = wrap_hl(colors.purple, "[%7(%l/%3L%):%2c %P]") end
        return ruler
    end
end

M.scrollbar = function()
    local curr_line = vim.api.nvim_win_get_cursor(utils.stwinnr())[1]
    local lines = vim.api.nvim_buf_line_count(utils.stbufnr())
    if lines == 0 then return string.rep(sbar[1], 2) end
    local i = math.floor((curr_line - 1) / lines * #sbar) + 1
    return wrap_hl(colors.blue, string.rep(sbar[i], 2))
end

-- test_status = function()
-- 	return table.concat({
-- 		M.diagnostics(),
-- 	})
-- end
--
-- vim.o.statusline = "%!v:lua.test_status()"

return M
