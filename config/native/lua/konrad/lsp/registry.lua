---@alias RegistryData {augroup: integer, bufnr: integer, client: lsp.Client}
---@alias RegisteredCommands {buf_commands?: string[], commands?: string[]}

---@class CapabilityHandler
---@field name string unique name of the handler
---@field attach fun(RegistryData): RegisteredCommands

-- track items that should be registered only once per buffer
-- maps bufrn -> { functionality_name -> client }
---@type table<integer, table<string, lsp.Client>>
local once_per_buffer = {}

-- client-id -> {command name->true} (global commands)
---@type table<integer, table<string, true>>
local commands = {}

-- client id -> {command name -> true}
---@type table<integer, table<string, true>>
local buf_commands = {}

---@param ttable table
---@param key any
---@param value table
local insert_into_nested = function(ttable, key, value)
    if not ttable[key] then ttable[key] = {} end

    local merged = vim.tbl_deep_extend("force", ttable[key], value)
    ttable[key] = merged
end

---@param list any[]
---@return table<any,true>
local list_into_set = function(list)
    local r = {}
    for _, value in ipairs(list) do
        r[value] = true
    end
    return r
end

local M = {}

---Useful for functionalities that should be registered only once per buffer
---in the case of multiple LSPs attaching to the same buffer.
---An example can be formatting.
---@param fname string name of the functionality
---@param data RegistryData
---@param handler CapabilityHandler
M.register_once = function(fname, data, handler)
    local bufnr = data.bufnr
    local client = data.client
    local buf_functionalities = once_per_buffer[bufnr] or {}
    local registered_client = buf_functionalities[fname]

    if registered_client then
        if registered_client.id == client.id then return end

        if registered_client.id ~= client.id and registered_client.name ~= client.name then
            local tmpl =
                "cannot enable '%s' for '%s (id:%d)' on buf:%d, already taken by '%s (id:%d)'"
            local msg = string.format(
                tmpl,
                fname,
                client.name,
                client.id,
                bufnr,
                registered_client.name,
                registered_client.id
            )
            vim.notify(msg, vim.log.levels.WARN)
            return
        end
    end

    local registered = handler.attach(handler)

    if registered.commands then
        insert_into_nested(commands, client.id, list_into_set(registered.commands))
    end
    if registered.buf_commands then
        insert_into_nested(buf_commands, client.id, list_into_set(registered.buf_commands))
    end
    insert_into_nested(once_per_buffer, bufnr, { [fname] = { id = client.id, name = client.name } })
end

---Call this to clean-up after any generic lsp.
---Stuff like codelens clearing or other specific functionalities is not handled here.
---@param client lsp.Client
---@param bufnr integer
M.deregister = function(client, bufnr)
    -- commands
    local client_commands = commands[client.id]
    if client_commands then
        for cmd, _ in pairs(client_commands) do
            pcall(vim.api.nvim_del_user_command, cmd)
        end
        commands[client.id] = nil
    end

    -- buf commands
    local client_buf_commands = buf_commands[client.id]
    if client_buf_commands then
        for buf_cmd, _ in pairs(client_buf_commands) do
            pcall(vim.api.nvim_buf_del_user_command, bufnr, buf_cmd)
        end
        buf_commands[client.id] = nil
    end

    -- once-per-buffer functionalities
    local buf_functionalities = once_per_buffer[bufnr]
    if buf_functionalities then
        for fname, registered_client in pairs(once_per_buffer) do
            if registered_client.id == client.id then buf_functionalities[fname] = nil end
        end
    end
end

return M
