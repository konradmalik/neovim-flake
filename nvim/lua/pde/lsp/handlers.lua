local augroups = require("pde.lsp.augroups")
local keymapper = require("pde.lsp.keymapper")
local telescope = require("telescope.builtin")
local ms = vim.lsp.protocol.Methods

---@alias HandlerData {augroup: integer, bufnr: integer, client: vim.lsp.Client}

---@class CapabilityHandler
---@field attach fun(data: HandlerData)
---@field detach fun(client_id: integer?, bufnr: integer)

local M = {}

---@param client vim.lsp.Client
---@param bufnr integer
function M.detach(client, bufnr)
    local client_id = client.id
    augroups.del_autocmds_for_buf(client, bufnr)

    local function client_buf_supports_method(method) return client:supports_method(method, bufnr) end

    local all_clients = vim.lsp.get_clients({ bufnr = bufnr })
    local function other_client_buf_supports_method(method)
        for _, c in ipairs(all_clients) do
            if c.id ~= client_id and c:supports_method(method, bufnr) then return true end
        end
        return false
    end

    local function client_yes_others_not_buf_supports_method(method)
        return client_buf_supports_method(method) and not other_client_buf_supports_method(method)
    end

    if client_buf_supports_method(ms.textDocument_codeLens) then
        require("pde.lsp.capabilities.textDocument_codeLens").detach(client_id, bufnr)
    end

    if client_buf_supports_method(ms.textDocument_completion) then
        require("pde.lsp.capabilities.textDocument_completion").detach(client_id, bufnr)
    end

    if client_buf_supports_method(ms.textDocument_inlineCompletion) then
        vim.lsp.inline_completion.enable(false, { client_id = client_id, bufnr = bufnr })
    end

    if client_yes_others_not_buf_supports_method(ms.textDocument_documentColor) then
        vim.lsp.document_color.enable(false, bufnr)
    end

    if client_yes_others_not_buf_supports_method(ms.textDocument_documentHighlight) then
        require("pde.lsp.capabilities.textDocument_documentHighlight").detach(nil, bufnr)
    end

    if client_yes_others_not_buf_supports_method(ms.textDocument_foldingRange) then
        require("pde.lsp.capabilities.textDocument_foldingRange").detach(nil, bufnr)
    end

    if client_buf_supports_method(ms.textDocument_formatting) then
        require("pde.lsp.capabilities.textDocument_formatting").detach(client_id, bufnr)
    end

    if client_buf_supports_method(ms.textDocument_onTypeFormatting) then
        vim.lsp.on_type_formatting.enable(false, { client_id = client_id })
    end

    if client_yes_others_not_buf_supports_method(ms.textDocument_inlayHint) then
        require("pde.lsp.capabilities.textDocument_inlayHint").detach(nil, bufnr)
    end

    if client_yes_others_not_buf_supports_method(ms.textDocument_linkedEditingRange) then
        vim.lsp.linked_editing_range.enable(false, { bufnr = bufnr })
    end

    if client_yes_others_not_buf_supports_method(ms.textDocument_semanticTokens_full) then
        vim.lsp.semantic_tokens.enable(false, { bufnr = bufnr })
    end

    -- Don't remove if more than 1 client attached
    -- 1 is allowed, since detach runs just before detaching from buffer
    if #all_clients <= 1 then keymapper.clear(bufnr) end
end

---@param client vim.lsp.Client
---@param bufnr integer
function M.attach(client, bufnr)
    local augroup = augroups.get_augroup(client)
    local opts_with_desc = keymapper.opts_for(bufnr)
    local function client_buf_supports_method(method) return client:supports_method(method, bufnr) end

    local handler_data = {
        augroup = augroup,
        bufnr = bufnr,
        client = client,
    }

    if client_buf_supports_method(ms.textDocument_completion) then
        require("pde.lsp.capabilities.textDocument_completion").attach(handler_data)
    end

    if client_buf_supports_method(ms.textDocument_inlineCompletion) then
        vim.lsp.inline_completion.enable(true, { client_id = client.id, bufnr = bufnr })
    end

    if client_buf_supports_method(ms.textDocument_codeLens) then
        require("pde.lsp.capabilities.textDocument_codeLens").attach(handler_data)
    end

    if client_buf_supports_method(ms.textDocument_foldingRange) then
        require("pde.lsp.capabilities.textDocument_foldingRange").attach(handler_data)
    end

    if client_buf_supports_method(ms.textDocument_formatting) then
        require("pde.lsp.capabilities.textDocument_formatting").attach(handler_data)
    end

    if client_buf_supports_method(ms.textDocument_onTypeFormatting) then
        vim.lsp.on_type_formatting.enable(true, { client_id = client.id })
    end

    if client_buf_supports_method(ms.textDocument_declaration) then
        vim.keymap.set("n", "grd", vim.lsp.buf.declaration, opts_with_desc("Go To Declaration"))
    end

    if client_buf_supports_method(ms.textDocument_definition) then
        vim.keymap.set("n", "<c-]>", telescope.lsp_definitions, opts_with_desc("Go To Definition"))
    end

    if client_buf_supports_method(ms.textDocument_documentColor) then
        vim.lsp.document_color.enable(true, bufnr)
    end

    if client_buf_supports_method(ms.textDocument_documentHighlight) then
        require("pde.lsp.capabilities.textDocument_documentHighlight").attach(handler_data)
    end

    if client_buf_supports_method(ms.textDocument_documentSymbol) then
        vim.keymap.set(
            "n",
            "gO",
            telescope.lsp_document_symbols,
            opts_with_desc("Document Symbols")
        )
    end

    if client_buf_supports_method(ms.workspace_symbol) then
        vim.keymap.set(
            "n",
            "gwO",
            telescope.lsp_dynamic_workspace_symbols,
            opts_with_desc("Workspace Symbols")
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

    if client_buf_supports_method(ms.textDocument_linkedEditingRange) then
        vim.lsp.linked_editing_range.enable(true, { bufnr = bufnr })
    end

    if client_buf_supports_method(ms.textDocument_semanticTokens_full) then
        vim.lsp.semantic_tokens.enable(true, { bufnr = bufnr })
    end

    if client_buf_supports_method(ms.textDocument_references) then
        vim.keymap.set("n", "grr", telescope.lsp_references, opts_with_desc("Go To References"))
    end

    if
        client_buf_supports_method(ms.workspace_willRenameFiles)
        or client_buf_supports_method(ms.workspace_didRenameFiles)
    then
        vim.keymap.set(
            "n",
            "grfn",
            require("pde.lsp.rename").rename_file,
            opts_with_desc("Rename current file")
        )
    end

    if client_buf_supports_method(ms.textDocument_signatureHelp) then
        vim.keymap.set("n", "grs", vim.lsp.buf.signature_help, opts_with_desc("Signature Help"))
    end

    if client_buf_supports_method(ms.textDocument_typeDefinition) then
        vim.keymap.set(
            "n",
            "grt",
            telescope.lsp_type_definitions,
            opts_with_desc("Type Definition")
        )
    end

    if client_buf_supports_method(ms.textDocument_inlayHint) then
        require("pde.lsp.capabilities.textDocument_inlayHint").attach(handler_data)
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
