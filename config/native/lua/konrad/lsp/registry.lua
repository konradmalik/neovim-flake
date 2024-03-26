---@alias RegistryData {augroup: integer, bufnr: integer, client: vim.lsp.Client}
---@alias RegisteredCommands {buf_commands?: string[], commands?: string[]}

---@class CapabilityHandler
---@field name string unique name of the handler
---@field attach fun(data: RegistryData)
---@field detach fun(client_id: integer, bufnr: integer)

-- track items that should be registered only once per buffer
-- maps bufrn -> { functionality_name -> client data }
---@type table<string, table<string, {id: integer, name: string}>>
local once_per_buffer = {}

---@param ttable table
---@param key any
---@param value table
local insert_into_nested = function(ttable, key, value)
    ttable[key] = vim.tbl_deep_extend("force", ttable[key] or {}, value)
end

local M = {}

---useful for debugging
---@return {once_per_buffer: table}
M.current_state = function()
    return {
        once_per_buffer = once_per_buffer,
    }
end

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

    handler.attach(data)
    insert_into_nested(once_per_buffer, bufnr, { [fname] = { id = client.id, name = client.name } })
end

---Call this to clean-up after any generic lsp.
---Stuff like codelens clearing or other specific functionalities is not handled here.
---@param client vim.lsp.Client
---@param bufnr integer
M.deregister = function(client, bufnr)
    local buf_functionalities = once_per_buffer[bufnr]
    if buf_functionalities then
        for fname, registered_client in pairs(buf_functionalities) do
            if registered_client.id == client.id then buf_functionalities[fname] = nil end
        end
    end
end

return M
