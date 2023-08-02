local keymapper = require('konrad.lsp.keymapper')

-- track items that should be registered only once per buffer
-- this is a mapping 'name-bufnr' -> client
local once_per_buffer = {}

-- client-id to command name
local commands = {};
-- client id to buf command name (don't need to store buf here since del requires a buf arg so we won't delete stuff by
-- accident)
local buf_commands = {};

---@param ttable table
---@param key any
---@param value any
local insert_into_nested = function(ttable, key, value)
    if not ttable[key] then
        ttable[key] = {}
    end
    if vim.tbl_islist(value) then
        vim.list_extend(ttable[key], value)
    else
        table.insert(ttable[key], value)
    end
end

local M = {}

---Useful for functionalities that should be registered only once per buffer
---in the case of multiple lsps attaching to the same buffer.
---An example can be formatting.
---@param name string
---@param data table of
---augroup integer
---bufnr integer
---client table
---@param setup function takes a table containing all above params
M.register_once = function(name, data, setup)
    local bufnr = data.bufnr
    local client = data.client
    local key = name .. '-' .. bufnr
    local registered_client = once_per_buffer[key]

    if registered_client then
        if registered_client.id == client.id then
            return
        end

        local tmpl = "cannot enable %s for '%s' on buf:%d, already enabled by '%s'"
        local msg = string.format(tmpl, name, client.name, bufnr, registered_client.name)
        vim.notify(msg, vim.log.levels.WARN)
    else
        local registered = setup(vim.tbl_extend('error', data, { name = name }))
        if registered['commands'] then
            insert_into_nested(commands, client.id, registered.commands)
        end
        if registered['buf_commands'] then
            insert_into_nested(buf_commands, client.id, registered.buf_commands)
        end
        once_per_buffer[key] = client
    end
end

---Call this to clean-up after any generic lsp.
---Stuff like codelens clearing or other specific functionalities is not handled here.
---@param augroup any
---@param client any
---@param bufnr any
M.deregister = function(augroup, client, bufnr)
    -- commands
    local client_commands = commands[client.id]
    if client_commands then
        for _, cmd in ipairs(client_commands) do
            pcall(vim.api.nvim_del_user_command, cmd)
        end
    end

    -- buf commands
    local client_buf_commands = buf_commands[client.id]
    if client_buf_commands then
        for _, buf_cmd in ipairs(client_buf_commands) do
            pcall(vim.api.nvim_buf_del_user_command, bufnr, buf_cmd)
        end
    end

    -- once-per-buffer functionalities
    for key, registered_client in pairs(once_per_buffer) do
        if vim.endswith(key, '-' .. bufnr) then
            if registered_client.id == client.id then
                once_per_buffer[key] = nil
            end
        end
    end

    -- keymaps
    local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
    -- don't remove if more than 1 client attached
    -- 1 is allowed, since detach runs just before detaching from buffer
    if #clients <= 1 then
        for _, mode in ipairs({ 'n', 'i', 'v' }) do
            local keymaps = vim.api.nvim_buf_get_keymap(bufnr, mode)
            for _, keymap in ipairs(keymaps) do
                if keymap.desc then
                    if vim.startswith(keymap.desc, keymapper.prefix) then
                        pcall(vim.api.nvim_buf_del_keymap, bufnr, mode, keymap.lhs)
                    end
                end
            end
        end
    end
end

return M
