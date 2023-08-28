local telescope = require('telescope.builtin')
local keymapper = require('konrad.lsp.keymapper')
local registry = require('konrad.lsp.registry')
local augroups = require('konrad.lsp.augroups')

local M = {}

---@param client table
---@param bufnr integer
M.detach = function(client, bufnr)
    augroups.del_autocmds_for_buf(client, bufnr)

    if client.supports_method("textDocument/codeLens") then
        require('konrad.lsp.capability_handlers.codelens').detach()
    end

    if client.supports_method("textDocument/inlayHint") then
        require('konrad.lsp.capability_handlers.inlayhints').detach()
    end

    registry.deregister(client, bufnr)

    local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
    -- don't remove if more than 1 client attached
    -- 1 is allowed, since detach runs just before detaching from buffer
    if #clients <= 1 then
        keymapper.clear(bufnr)
    end
end

M.attach = function(client, bufnr)
    local augroup = augroups.get_augroup(client)
    local opts_with_desc = keymapper.setup(bufnr)
    local register_data = {
        augroup = augroup,
        bufnr = bufnr,
        client = client,
    }
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

    if client.supports_method("textDocument/codeAction") then
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts_with_desc("Code Action"))
    end

    if client.supports_method("textDocument/codeLens") then
        registry.register_once("CodeLens", register_data, require('konrad.lsp.capability_handlers.codelens').attach)
    end

    if client.supports_method("textDocument/formatting") then
        registry.register_once("Formatting", register_data, require('konrad.lsp.capability_handlers.format').setup)
    end

    if client.supports_method("textDocument/documentHighlight") then
        registry.register_once("DocumentHighlighting", register_data,
            require('konrad.lsp.capability_handlers.documenthighlight').setup)
    end

    if client.supports_method("textDocument/documentSymbol") then
        registry.register_once("Navic", register_data, require("konrad.lsp.capability_handlers.navic").setup)
    end

    if client.supports_method("textDocument/declaration") then
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts_with_desc("Go To Declaration"))
    end

    if client.supports_method("textDocument/definition") then
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts_with_desc("Go To Definition"))
        vim.keymap.set("n", "<leader>fd", telescope.lsp_definitions, opts_with_desc("Telescope [D]efinitions"))
    end

    if client.supports_method("textDocument/hover") then
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts_with_desc("Hover"))
    end

    if client.supports_method("textDocument/implementation") then
        vim.keymap.set("n", "gp", vim.lsp.buf.implementation, opts_with_desc("Go To Implementation"))
        vim.keymap.set("n", "<leader>fp", telescope.lsp_implementations,
            opts_with_desc("Telescope Im[p]lementations"))
    end

    if client.supports_method("textDocument/references") then
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts_with_desc("References"))
        vim.keymap.set("n", "<leader>fr", telescope.lsp_references, opts_with_desc("Telescope [R]eferences"))
    end

    if client.supports_method("textDocument/rename") then
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts_with_desc("Rename"))
    end

    if client.supports_method("textDocument/signatureHelp") then
        vim.keymap.set("n", "gs", vim.lsp.buf.signature_help, opts_with_desc("Signature Help"))
    end

    if client.supports_method("textDocument/typeDefinition") then
        vim.keymap.set("n", "gT", vim.lsp.buf.type_definition, opts_with_desc("Go To Type Definition"))
        vim.keymap.set("n", "<leader>fT", telescope.lsp_type_definitions,
            opts_with_desc("Telescope [T]ype Definitions"))
    end

    if client.supports_method("workspaceSymbol/resolve") then
        vim.keymap.set("n", "<leader>ws", vim.lsp.buf.workspace_symbol, opts_with_desc("Search workspace symbols"))
        vim.keymap.set("n", "<leader>fws", telescope.lsp_workspace_symbols,
            opts_with_desc("Telescope [W]orkspace [S]ymbols"))
    end

    if client.supports_method("textDocument/inlayHint") then
        registry.register_once("InlayHints", register_data, require('konrad.lsp.capability_handlers.inlayhints').attach)
    end

    vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts_with_desc("Add Workspace Folder"))
    vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts_with_desc("Remove Workspace Folder"))
    vim.keymap.set("n", "<leader>wl", function() P(vim.lsp.buf.list_workspace_folders()) end,
        opts_with_desc("List Workspace Folders"))
end

return M
