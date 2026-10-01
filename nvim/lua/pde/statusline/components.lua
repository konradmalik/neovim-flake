local cache = require("pde.statusline.cache")
local icons = require("pde.statusline.icons")
local mini_icons = require("mini.icons")

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
    diag_ok = "DiagnosticOk",
    git_del = "diffDeleted",
    git_add = "diffAdded",
    git_change = "diffChanged",
    directory = "Directory",
    filetype = "Type",
}

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
    ["s"] = { "^Vs", colors.special },

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

---@class pde.statusline.components
local M = {}

M.space = " "

M.align = "%="

M.cut = "%<"

---@param bufnr integer
---@return string
M.busy = function(bufnr)
    local busy = vim.bo[bufnr].busy
    if busy == 0 then return "" end
    return wrap_hl(colors.statement, "<buffer is busy>")
end

---@type table<string, string> source highlight group -> mode highlight group
local mode_hls = {}

vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("StModeHl", { clear = true }),
    callback = function() mode_hls = {} end,
    desc = "recreate statusline mode highlights",
})

--- Returns a bold highlight group with `group`'s fg as its bg, creating it on first use.
---@param group string
---@return string
local function mode_hl(group)
    if not mode_hls[group] then
        local name = "StMode" .. group
        local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
        vim.api.nvim_set_hl(0, name, { bold = true, bg = hl.fg, fg = "bg" })
        mode_hls[group] = name
    end
    return mode_hls[group]
end

M.mode = function()
    local m = modes[vim.api.nvim_get_mode().mode] or modes["n"]

    local mname = m[1]
    local mhl = m[2]

    local left = wrap_hl(mhl, icons.ui.LeftHalf)
    local right = wrap_hl(mhl, icons.ui.RightHalf)

    local mode = wrap_hl(mode_hl(mhl), icons.misc.Neovim .. " " .. mname)

    return left .. mode .. right
end

---@param bufnr integer
---@param active boolean
---@return string
M.fileinfo = function(bufnr, active)
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    local icon, ihl, _ = mini_icons.get("file", bufname)
    local filename = bufname == "" and "[No Name]" or vim.fn.fnamemodify(bufname, ":.")

    if not active then
        -- NonText only sets fg
        return wrap_hl(colors.nontext, icon .. " " .. filename)
    end

    return wrap_hl(ihl, icon) .. " " .. filename
end

---@param bufnr integer
---@return string
M.filemod = function(bufnr)
    if vim.bo[bufnr].modified then return wrap_hl(colors.diag_ok, icons.git.Mod) end

    local text = ""
    if vim.bo[bufnr].readonly then text = text .. wrap_hl(colors.diag_warn, icons.ui.Lock) end
    if not vim.bo[bufnr].modifiable then text = text .. wrap_hl(colors.diag_error, icons.ui.FilledLock) end

    return text
end

---@param bufnr integer
---@return string
M.fileformat = function(bufnr) return wrap_hl(colors.nontext, format_types[vim.bo[bufnr].fileformat]) end

---@param bufnr integer
---@return string
M.git = function(bufnr)
    local head = vim.b[bufnr].gitsigns_head
    if not head then return "" end
    return wrap_click("git_click", wrap_hl(colors.constant, icons.git.Branch .. " " .. head))
end

M.gitchanges = (function()
    vim.api.nvim_create_autocmd("User", {
        group = vim.api.nvim_create_augroup("StGitUpdate", { clear = true }),
        pattern = "GitSignsUpdate",
        callback = vim.schedule_wrap(function() vim.cmd.redrawstatus() end),
        desc = "updates statusline every time git status is updated",
    })

    local git_parts = {
        { key = "added", hl = colors.git_add, icon = icons.git.Add },
        { key = "changed", hl = colors.git_change, icon = icons.git.Mod },
        { key = "removed", hl = colors.git_del, icon = icons.git.Remove },
    }

    ---@param bufnr integer
    ---@return string
    return function(bufnr)
        local git_status = vim.b[bufnr].gitsigns_status_dict
        if not git_status then return "" end

        local text = ""
        for _, part in ipairs(git_parts) do
            local count = git_status[part.key]
            if count and count ~= 0 then text = text .. wrap_hl(part.hl, part.icon .. " " .. count .. " ") end
        end

        if text == "" then return "" end
        return wrap_click("git_click", text)
    end
end)()

M.git_click = function() vim.cmd("Git") end

---@param bufnr integer
---@return string
M.diagnostics = function(bufnr)
    if not vim.diagnostic.is_enabled({ bufnr = bufnr }) then return "" end
    return vim.diagnostic.status(bufnr)
end

---@param bufnr integer
---@return string
M.filetype = function(bufnr)
    local ft = vim.bo[bufnr].filetype
    if ft == "" then ft = "plain text" end
    return wrap_hl(colors.filetype, icons.documents.FileContents .. " " .. ft)
end

---@param bufnr integer
---@return string
M.file_encoding = function(bufnr)
    local encode = vim.bo[bufnr].fileencoding
    if encode == "" then encode = vim.o.encoding end
    return wrap_hl(colors.nontext, encode:lower())
end

M.LSP_status = cache.create(
    ---@param bufnr integer
    ---@return string
    function(bufnr)
        local clients = vim.lsp.get_clients({ bufnr = bufnr })
        local numClients = #clients
        if numClients == 0 then return "" end

        local icon = numClients > 1 and icons.ui.HexagonAll or icons.ui.Hexagon
        local text
        if numClients >= 4 then
            text = icon .. " " .. numClients .. " LSPs"
        else
            local texts = { icon }
            for _, server in ipairs(clients) do
                table.insert(texts, server.name)
            end
            text = table.concat(texts, " ")
        end
        return wrap_click("LSP_click", wrap_hl(colors.string, text))
    end,
    {
        events = { "LspAttach", "LspDetach" },
        buffer = true,
    }
)

M.LSP_click = function() vim.cmd("checkhealth lsp") end

M.cwd = cache.create(
    ---@param winid integer
    ---@return string
    function(winid)
        local cwd = vim.fn.getcwd(winid)
        cwd = vim.fn.fnamemodify(cwd, ":t")
        cwd = (vim.fn.haslocaldir(winid) == 1 and "l" or "g") .. " " .. icons.documents.Folder .. " " .. cwd
        return wrap_hl(colors.directory, cwd)
    end,
    {
        events = { "WinEnter", "DirChanged" },
    }
)

M.ruler = wrap_hl(colors.statement, "[%7(%l/%3L%):%2c %P]")

return M
