local augroups = require("pde.lsp.augroups")
local keymapper = require("pde.lsp.keymapper")
local telescope = require("telescope.builtin")
local ms = vim.lsp.protocol.Methods

---@alias HandlerData {augroup: integer, bufnr: integer, client: vim.lsp.Client}

---@class CapabilityHandler
---@field attach fun(data: HandlerData)
---@field detach fun(client_id: integer, bufnr: integer)

local M = {}

---@param client vim.lsp.Client
---@param bufnr integer
M.detach = function(client, bufnr)
    local client_id = client.id
    augroups.del_autocmds_for_buf(client, bufnr)
    local function client_buf_supports_method(method)
        return client.supports_method(method, { bufnr = bufnr })
    end

    if client_buf_supports_method(ms.textDocument_codeLens) then
        require("pde.lsp.capability_handlers.codelens").detach(client_id, bufnr)
    end

    if client_buf_supports_method(ms.textDocument_documentHighlight) then
        require("pde.lsp.capability_handlers.documenthighlight").detach(client_id, bufnr)
    end

    if client_buf_supports_method(ms.textDocument_formatting) then
        require("pde.lsp.capability_handlers.format").detach(client_id, bufnr)
    end

    if client_buf_supports_method(ms.textDocument_inlayHint) then
        require("pde.lsp.capability_handlers.inlayhints").detach(client_id, bufnr)
    end

    local clients = vim.lsp.get_clients({ bufnr = bufnr })
    -- don't remove if more than 1 client attached
    -- 1 is allowed, since detach runs just before detaching from buffer
    if #clients <= 1 then keymapper.clear(bufnr) end
end

---@param client vim.lsp.Client
---@param bufnr integer
M.attach = function(client, bufnr)
    local augroup = augroups.get_augroup(client)
    local opts_with_desc = keymapper.opts_for(bufnr)
    local function client_buf_supports_method(method)
        return client.supports_method(method, { bufnr = bufnr })
    end

    local handler_data = {
        augroup = augroup,
        bufnr = bufnr,
        client = client,
    }

    if client_buf_supports_method(ms.textDocument_completion) then
        local completion = require("pde.lsp.completion")
        completion.enable(client, bufnr)

        if client_buf_supports_method(ms.completionItem_resolve) then
            completion.enable_completion_documentation(client, augroup, bufnr)
        end
    end

    if client_buf_supports_method(ms.textDocument_hover) then
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts_with_desc("Hover Documentation"))
    end

    if client_buf_supports_method(ms.textDocument_codeAction) then
        vim.keymap.set({ "n", "x" }, "gra", vim.lsp.buf.code_action, opts_with_desc("Code Action"))
    end

    if client_buf_supports_method(ms.textDocument_codeLens) then
        require("pde.lsp.capability_handlers.codelens").attach(handler_data)
    end

    if client_buf_supports_method(ms.textDocument_formatting) then
        require("pde.lsp.capability_handlers.format").attach(handler_data)
    end

    if client_buf_supports_method(ms.textDocument_declaration) then
        vim.keymap.set("n", "gd", vim.lsp.buf.declaration, opts_with_desc("Go To Declaration"))
    end

    if client_buf_supports_method(ms.textDocument_definition) then
        vim.keymap.set("n", "<c-]>", telescope.lsp_definitions, opts_with_desc("Go To Definition"))
    end

    if client_buf_supports_method(ms.textDocument_documentHighlight) then
        require("pde.lsp.capability_handlers.documenthighlight").attach(handler_data)
    end

    if client_buf_supports_method(ms.textDocument_documentSymbol) then
        vim.keymap.set(
            "n",
            "grds",
            telescope.lsp_document_symbols,
            opts_with_desc("Document Symbols")
        )
    end

    if client_buf_supports_method(ms.textDocument_implementation) then
        vim.keymap.set(
            "n",
            "gri",
            telescope.lsp_implementations,
            opts_with_desc("Go To Implementation")
        )
    end

    if client_buf_supports_method(ms.textDocument_references) then
        vim.keymap.set("n", "grr", telescope.lsp_references, opts_with_desc("Go To References"))
    end

    if client_buf_supports_method(ms.textDocument_rename) then
        vim.keymap.set("n", "grn", vim.lsp.buf.rename, opts_with_desc("Rename"))
    end

    if client_buf_supports_method(ms.textDocument_signatureHelp) then
        vim.keymap.set("n", "grs", vim.lsp.buf.signature_help, opts_with_desc("Signature Help"))
        vim.keymap.set("i", "<c-s>", vim.lsp.buf.signature_help, opts_with_desc("Signature Help"))
    end

    if client_buf_supports_method(ms.textDocument_typeDefinition) then
        vim.keymap.set("n", "gD", telescope.lsp_type_definitions, opts_with_desc("Type Definition"))
    end

    if client_buf_supports_method(ms.workspace_symbol) then
        vim.keymap.set(
            "n",
            "grws",
            telescope.lsp_dynamic_workspace_symbols,
            opts_with_desc("Workspace Symbols")
        )
    end

    if client_buf_supports_method(ms.textDocument_inlayHint) then
        require("pde.lsp.capability_handlers.inlayhints").attach(handler_data)
    end

    vim.keymap.set(
        "n",
        "grwa",
        vim.lsp.buf.add_workspace_folder,
        opts_with_desc("Add Workspace Folder")
    )
    vim.keymap.set(
        "n",
        "grwr",
        vim.lsp.buf.remove_workspace_folder,
        opts_with_desc("Remove Workspace Folder")
    )
    vim.keymap.set(
        "n",
        "grwl",
        function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end,
        opts_with_desc("List Workspace Folders")
    )
end

return M
