local augroups = require("pde.lsp.augroups")
local keymapper = require("pde.lsp.keymapper")
local telescope = require("telescope.builtin")
local ms = vim.lsp.protocol.Methods

---@alias HandlerData {augroup: integer, bufnr: integer, client: vim.lsp.Client}

---@class CapabilityHandler
---@field attach fun(data: HandlerData)
---@field detach fun(client_id: integer, bufnr: integer)

---@param client vim.lsp.Client
---@param bufnr integer
local function detach(client, bufnr)
    local client_id = client.id
    augroups.del_autocmds_for_buf(client, bufnr)
    local function client_buf_supports_method(method) return client:supports_method(method, bufnr) end

    if client_buf_supports_method(ms.textDocument_codeLens) then
        require("pde.lsp.capabilities.textDocument_codeLens").detach(client_id, bufnr)
    end

    if client_buf_supports_method(ms.textDocument_completion) then
        require("pde.lsp.capabilities.textDocument_completion").detach(client_id, bufnr)
    end

    if client_buf_supports_method(ms.textDocument_documentHighlight) then
        require("pde.lsp.capabilities.textDocument_documentHighlight").detach(client_id, bufnr)
    end

    if client_buf_supports_method(ms.textDocument_foldingRange) then
        require("pde.lsp.capabilities.textDocument_foldingRange").detach(client_id, bufnr)
    end

    if client_buf_supports_method(ms.textDocument_formatting) then
        require("pde.lsp.capabilities.textDocument_formatting").detach(client_id, bufnr)
    end

    if client_buf_supports_method(ms.textDocument_inlayHint) then
        require("pde.lsp.capabilities.textDocument_inlayHint").detach(client_id, bufnr)
    end

    local clients = vim.lsp.get_clients({ bufnr = bufnr })
    -- don't remove if more than 1 client attached
    -- 1 is allowed, since detach runs just before detaching from buffer
    if #clients <= 1 then keymapper.clear(bufnr) end
end

---@param client vim.lsp.Client
---@param bufnr integer
local function attach(client, bufnr)
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

    if client_buf_supports_method(ms.textDocument_hover) then
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts_with_desc("Hover Documentation"))
    end

    if client_buf_supports_method(ms.textDocument_codeAction) then
        vim.keymap.set({ "n", "x" }, "gra", vim.lsp.buf.code_action, opts_with_desc("Code Action"))
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

    if client_buf_supports_method(ms.textDocument_declaration) then
        vim.keymap.set("n", "gd", vim.lsp.buf.declaration, opts_with_desc("Go To Declaration"))
    end

    if client_buf_supports_method(ms.textDocument_definition) then
        vim.keymap.set("n", "<c-]>", telescope.lsp_definitions, opts_with_desc("Go To Definition"))
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

    if client_buf_supports_method(ms.textDocument_references) then
        vim.keymap.set("n", "grr", telescope.lsp_references, opts_with_desc("Go To References"))
    end

    if client_buf_supports_method(ms.textDocument_rename) then
        vim.keymap.set("n", "grn", vim.lsp.buf.rename, opts_with_desc("Rename"))
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
        vim.keymap.set("i", "<c-s>", vim.lsp.buf.signature_help, opts_with_desc("Signature Help"))
    end

    if client_buf_supports_method(ms.textDocument_typeDefinition) then
        vim.keymap.set("n", "gD", telescope.lsp_type_definitions, opts_with_desc("Type Definition"))
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

local M = {}

---Initialize lsp configurations
function M.setup()
    require("pde.lsp.autoclose")
    require("pde.lsp.commands")
    require("pde.lsp.progress")

    vim.lsp.config("*", {
        root_markers = {
            ".git",
        },
    })

    local group = vim.api.nvim_create_augroup("personal-lsp", { clear = true })

    vim.api.nvim_create_autocmd("LspAttach", {
        group = group,
        callback = function(args)
            local client_id = args.data.client_id
            local client = vim.lsp.get_client_by_id(client_id)
            if client then
                attach(client, args.buf)
            else
                vim.notify("cannot find client " .. client_id, vim.log.levels.ERROR)
            end
        end,
    })

    vim.api.nvim_create_autocmd("LspDetach", {
        group = group,
        callback = function(args)
            local client_id = args.data.client_id
            local client = vim.lsp.get_client_by_id(client_id)
            if client then
                detach(client, args.buf)
            else
                vim.notify("cannot find client " .. client_id, vim.log.levels.ERROR)
            end
        end,
    })
end

return M
