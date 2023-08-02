local telescope = require('telescope.builtin')
local keymapper = require('konrad.lsp.keymapper')

local M = {}

-- client id to group id mapping
local _augroups = {}

---@param client table
---@return integer
local get_augroup = function(client)
    if not _augroups[client.id] then
        local group_name = string.format('personal-lsp-%s-%d', client.name, client.id)
        local group = vim.api.nvim_create_augroup(group_name, { clear = true })
        _augroups[client.id] = group
        return group
    end
    return _augroups[client.id]
end

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

M.detach = function(client, bufnr)
    local augroup = get_augroup(client)
    local aucmds = vim.api.nvim_get_autocmds({
        group = augroup,
        buffer = bufnr,
    })
    for _, aucmd in ipairs(aucmds) do
        pcall(vim.api.nvim_del_autocmd, aucmd.id)
    end

    local client_commands = commands[client.id]
    if client_commands then
        for _, cmd in ipairs(client_commands) do
            pcall(vim.api.nvim_del_user_command, cmd)
        end
    end

    local client_buf_commands = buf_commands[client.id]
    if client_buf_commands then
        for _, buf_cmd in ipairs(client_buf_commands) do
            pcall(vim.api.nvim_buf_del_user_command, bufnr, buf_cmd)
        end
    end

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

    pcall(vim.lsp.codelens.clear)
    local inlayhints_ok, inlayhints = pcall(require, 'lsp-inlayhints')
    if inlayhints_ok then inlayhints.reset() end
end

-- track items that should be registered only once per buffer
-- this is a mapping 'name-bufnr' -> client.name
local once_per_buffer = {}
---comment
---@param name string
---@param data table of
---augroup integer
---bufnr integer
---client table
---@param setup function takes a table containing all above params
local register_once = function(name, data, setup)
    local bufnr = data.bufnr
    local client = data.client
    local key = name .. '-' .. tostring(bufnr)
    local registered_client = once_per_buffer[key]

    if registered_client then
        local tmpl = "cannot enable %s for '%s' on buf:%d, already enabled by '%s'"
        local msg = string.format(tmpl, name, client.name, bufnr, registered_client)
        vim.notify(msg, vim.log.levels.WARN)
    else
        local registered = setup(vim.tbl_extend('error', data, { name = name }))
        if registered['commands'] then
            insert_into_nested(commands, client.id, registered.commands)
        end
        if registered['buf_commands'] then
            insert_into_nested(buf_commands, client.id, registered.buf_commands)
        end
        once_per_buffer[key] = client.name
    end
end

M.attach = function(client, bufnr)
    local capabilities = client.server_capabilities
    local augroup = get_augroup(client)
    local opts_with_desc = keymapper.setup(bufnr)
    local register_data = {
        augroup = augroup,
        bufnr = bufnr,
        client = client,
    }

    if capabilities.codeActionProvider then
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts_with_desc("Code Action"))
    end

    if capabilities.codeLensProvider then
        register_once("CodeLens", register_data, require('konrad.lsp.capability_handlers.codelens').setup)
    end

    if capabilities.documentFormattingProvider then
        register_once("Formatting", register_data, require('konrad.lsp.capability_handlers.format').setup)
    end

    if capabilities.documentHighlightProvider then
        register_once("DocumentHighlighting", register_data,
            require('konrad.lsp.capability_handlers.documenthighlight').setup)
    end

    if capabilities.declarationProvider then
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts_with_desc("Go To Declaration"))
    end

    if capabilities.definitionProvider then
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts_with_desc("Go To Definition"))
        vim.keymap.set("n", "<leader>fd", telescope.lsp_definitions, opts_with_desc("Telescope [D]efinitions"))
    end

    if capabilities.hoverProvider then
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts_with_desc("Hover"))
    end

    if capabilities.implementationProvider then
        vim.keymap.set("n", "gp", vim.lsp.buf.implementation, opts_with_desc("Go To Implementation"))
        vim.keymap.set("n", "<leader>fp", telescope.lsp_implementations,
            opts_with_desc("Telescope Im[p]lementations"))
    end

    if capabilities.referencesProvider then
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts_with_desc("References"))
        vim.keymap.set("n", "<leader>fr", telescope.lsp_references, opts_with_desc("Telescope [R]eferences"))
    end

    if capabilities.renameProvider then
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts_with_desc("Rename"))
    end

    if capabilities.signatureHelpProvider then
        vim.keymap.set("n", "gs", vim.lsp.buf.signature_help, opts_with_desc("Signature Help"))
    end

    if capabilities.typeDefinitionProvider then
        vim.keymap.set("n", "gT", vim.lsp.buf.type_definition, opts_with_desc("Go To Type Definition"))
        vim.keymap.set("n", "<leader>fT", telescope.lsp_type_definitions,
            opts_with_desc("Telescope [T]ype Definitions"))
    end

    if capabilities.workspaceSymbolProvider then
        vim.keymap.set("n", "<leader>ws", vim.lsp.buf.workspace_symbol, opts_with_desc("Search workspace symbols"))
        vim.keymap.set("n", "<leader>fws", telescope.lsp_workspace_symbols,
            opts_with_desc("Telescope [W]orkspace [S]ymbols"))
    end

    if capabilities.inlayHintProvider then
        register_once("InlayHints", register_data, require('konrad.lsp.capability_handlers.inlayhints').setup)
    end

    vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts_with_desc("Add Workspace Folder"))
    vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts_with_desc("Remove Workspace Folder"))
    vim.keymap.set("n", "<leader>wl", function() P(vim.lsp.buf.list_workspace_folders()) end,
        opts_with_desc("List Workspace Folders"))
end

return M
