local augroups = require("konrad.lsp.augroups")
local keymapper = require("konrad.lsp.keymapper")
local protocol = require("vim.lsp.protocol")
local registry = require("konrad.lsp.registry")
local telescope = require("telescope.builtin")
local ms = protocol.Methods

local M = {}

---@param client vim.lsp.Client
---@param bufnr integer
M.detach = function(client, bufnr)
    augroups.del_autocmds_for_buf(client, bufnr)
    local function client_buf_supports_method(method)
        return client.supports_method(method, { bufnr = bufnr })
    end

    if client_buf_supports_method(ms.textDocument_codeAction) then
        require("konrad.lsp.capability_handlers.codeaction").detach()
    end

    if client_buf_supports_method(ms.textDocument_codeLens) then
        require("konrad.lsp.capability_handlers.codelens").detach({
            client_id = client.id,
            bufnr = bufnr,
        })
    end

    if client_buf_supports_method(ms.textDocument_documentHighlight) then
        require("konrad.lsp.capability_handlers.documenthighlight").detach()
    end

    if client_buf_supports_method(ms.textDocument_inlayHint) then
        require("konrad.lsp.capability_handlers.inlayhints").detach({ bufnr = bufnr })
    end

    registry.deregister(client, bufnr)

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

    local register_data = {
        augroup = augroup,
        bufnr = bufnr,
        client = client,
    }

    if client_buf_supports_method(ms.textDocument_hover) then
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts_with_desc("Hover Documentation"))
    end

    if client_buf_supports_method(ms.textDocument_codeAction) then
        local handler = require("konrad.lsp.capability_handlers.codeaction")
        registry.register_once(handler.name, register_data, handler)
    end

    if client_buf_supports_method(ms.textDocument_codeLens) then
        local handler = require("konrad.lsp.capability_handlers.codelens")
        registry.register_once(handler.name, register_data, handler)
    end

    if client_buf_supports_method(ms.textDocument_formatting) then
        local handler = require("konrad.lsp.capability_handlers.format")
        registry.register_once(handler.name, register_data, handler)
    end

    if client_buf_supports_method(ms.textDocument_declaration) then
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts_with_desc("Go To Declaration"))
    end

    if client_buf_supports_method(ms.textDocument_definition) then
        vim.keymap.set("n", "gd", telescope.lsp_definitions, opts_with_desc("Go To Definition"))
    end

    if client_buf_supports_method(ms.textDocument_documentHighlight) then
        local handler = require("konrad.lsp.capability_handlers.documenthighlight")
        registry.register_once(handler.name, register_data, handler)
    end

    if client_buf_supports_method(ms.textDocument_documentSymbol) then
        vim.keymap.set(
            "n",
            "<leader>ds",
            telescope.lsp_document_symbols,
            opts_with_desc("Document Symbols")
        )
    end

    if client_buf_supports_method(ms.textDocument_implementation) then
        vim.keymap.set(
            "n",
            "gI",
            telescope.lsp_implementations,
            opts_with_desc("Go To Implementation")
        )
    end

    if client_buf_supports_method(ms.textDocument_references) then
        vim.keymap.set("n", "gr", telescope.lsp_references, opts_with_desc("Go To References"))
    end

    if client_buf_supports_method(ms.textDocument_rename) then
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts_with_desc("Rename"))
    end

    if client_buf_supports_method(ms.textDocument_signatureHelp) then
        vim.keymap.set("n", "gs", vim.lsp.buf.signature_help, opts_with_desc("Signature Help"))
        vim.keymap.set("i", "<c-s>", vim.lsp.buf.signature_help, opts_with_desc("Signature Help"))
    end

    if client_buf_supports_method(ms.textDocument_typeDefinition) then
        vim.keymap.set(
            "n",
            "<leader>T",
            telescope.lsp_type_definitions,
            opts_with_desc("Type Definition")
        )
    end

    if client_buf_supports_method(ms.workspace_symbol) then
        vim.keymap.set(
            "n",
            "<leader>ws",
            telescope.lsp_dynamic_workspace_symbols,
            opts_with_desc("Workspace Symbols")
        )
    end

    if client_buf_supports_method(ms.textDocument_inlayHint) then
        local handler = require("konrad.lsp.capability_handlers.inlayhints")
        registry.register_once(handler.name, register_data, handler)
    end

    vim.keymap.set(
        "n",
        "<leader>wa",
        vim.lsp.buf.add_workspace_folder,
        opts_with_desc("Add Workspace Folder")
    )
    vim.keymap.set(
        "n",
        "<leader>wr",
        vim.lsp.buf.remove_workspace_folder,
        opts_with_desc("Remove Workspace Folder")
    )
    vim.keymap.set(
        "n",
        "<leader>wl",
        function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end,
        opts_with_desc("List Workspace Folders")
    )
end

return M
