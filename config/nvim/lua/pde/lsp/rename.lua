-- https://github.com/folke/snacks.nvim/blob/main/lua/snacks/rename.lua
local ms = vim.lsp.protocol.Methods
local timeout_ms = 2000

local M = {}

---@param path string
local function realpath(path) return vim.fs.normalize(vim.uv.fs_realpath(path) or path) end

-- Prompt for the new filename,
-- do the rename, and trigger LSP handlers
---@param opts? {file?: string, on_rename?: fun(new:string, old:string)}
function M.rename_file(opts)
    opts = opts or {}
    local buf = vim.api.nvim_get_current_buf()
    if opts.file then buf = vim.fn.bufadd(opts.file) end
    local old = assert(realpath(vim.api.nvim_buf_get_name(buf)))
    local root = assert(realpath(vim.uv.cwd() or "."))

    if old:find(root, 1, true) ~= 1 then root = vim.fn.fnamemodify(old, ":p:h") end

    local extra = old:sub(#root + 2)

    vim.ui.input({
        prompt = "New File Name: ",
        default = extra,
        completion = "file",
    }, function(new)
        if not new or new == "" or new == extra then return end
        new = vim.fs.normalize(vim.fs.joinpath(root, new))
        vim.fn.mkdir(vim.fs.dirname(new), "p")
        M.on_rename_file(old, new, function()
            vim.fn.rename(old, new)
            if not opts.on_rename then vim.cmd.edit(new) end
            vim.api.nvim_buf_delete(buf, { force = true })
            vim.fn.delete(old)
            if opts.on_rename then opts.on_rename(new, old) end
        end)
    end)
end

--- Lets LSP clients know that a file has been renamed
---@param from string
---@param to string
---@param rename? fun()
function M.on_rename_file(from, to, rename)
    local changes = {
        files = {
            {
                oldUri = vim.uri_from_fname(from),
                newUri = vim.uri_from_fname(to),
            },
        },
    }

    local clients = vim.lsp.get_clients()
    for _, client in ipairs(clients) do
        if client:supports_method(ms.workspace_willRenameFiles) then
            local resp = client:request_sync(ms.workspace_willRenameFiles, changes, timeout_ms, 0)
            if resp and resp.result ~= nil then
                vim.lsp.util.apply_workspace_edit(resp.result, client.offset_encoding)
            end
        end
    end

    if rename then rename() end

    for _, client in ipairs(clients) do
        if client:supports_method(ms.workspace_didRenameFiles) then
            client:notify(ms.workspace_didRenameFiles, changes)
        end
    end
end

return M
