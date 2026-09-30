local ms = vim.lsp.protocol.Methods
local keymapper = require("pde.lsp.keymapper")

---@class pde.lsp.Feature
---@field attach fun(client: vim.lsp.Client, bufnr: integer)
---@field detach fun(client: vim.lsp.Client, bufnr: integer)
---@field per_client? boolean detach for every client, not only the last one supporting the method

-- takes the module itself (not a string name), so lua_ls checks the field access
-- and the enable() call against this type.
-- a module that doesn't fit this shape gets a hand-written entry instead
---@param mod { enable: fun(enable?: boolean, filter?: { bufnr?: integer }) }
---@return pde.lsp.Feature
local function builtin(mod)
    return {
        attach = function(_, bufnr) mod.enable(true, { bufnr = bufnr }) end,
        detach = function(_, bufnr) mod.enable(false, { bufnr = bufnr }) end,
    }
end

---@param lhs string
---@param rhs function
---@param desc string
---@return pde.lsp.Feature
local function map(lhs, rhs, desc)
    return {
        attach = function(_, bufnr) keymapper.set(bufnr, lhs, rhs, desc) end,
        detach = function(_, bufnr) keymapper.del(bufnr, lhs) end,
    }
end

---@param picker string
---@return function
local function telescope(picker)
    return function() require("telescope.builtin")[picker]() end
end

---@type table<string, pde.lsp.Feature>
local features = {
    [ms.textDocument_codeLens] = require("pde.lsp.capabilities.textDocument_codeLens"),
    [ms.textDocument_completion] = require("pde.lsp.capabilities.textDocument_completion"),
    [ms.textDocument_documentHighlight] = require("pde.lsp.capabilities.textDocument_documentHighlight"),
    [ms.textDocument_foldingRange] = require("pde.lsp.capabilities.textDocument_foldingRange"),
    [ms.textDocument_formatting] = require("pde.lsp.capabilities.textDocument_formatting"),
    [ms.textDocument_inlayHint] = require("pde.lsp.capabilities.textDocument_inlayHint"),

    [ms.textDocument_documentColor] = builtin(vim.lsp.document_color),
    [ms.textDocument_inlineCompletion] = builtin(vim.lsp.inline_completion),
    [ms.textDocument_linkedEditingRange] = builtin(vim.lsp.linked_editing_range),
    [ms.textDocument_onTypeFormatting] = builtin(vim.lsp.on_type_formatting),
    [ms.textDocument_semanticTokens_full] = builtin(vim.lsp.semantic_tokens),

    [ms.textDocument_declaration] = map("grd", vim.lsp.buf.declaration, "Go To Declaration"),
    [ms.textDocument_definition] = map("<c-]>", telescope("lsp_definitions"), "Go To Definition"),
    [ms.textDocument_documentSymbol] = map("gO", telescope("lsp_document_symbols"), "Document Symbols"),
    [ms.textDocument_implementation] = map("gri", telescope("lsp_implementations"), "Go To Implementation"),
    [ms.textDocument_references] = map("grr", telescope("lsp_references"), "Go To References"),
    [ms.textDocument_signatureHelp] = map("grs", vim.lsp.buf.signature_help, "Signature Help"),
    [ms.textDocument_typeDefinition] = map("grt", telescope("lsp_type_definitions"), "Type Definition"),
    [ms.workspace_symbol] = map("gwO", telescope("lsp_dynamic_workspace_symbols"), "Workspace Symbols"),
}

-- file rename needs either of two methods, so it lives outside the one-method features table
---@param client vim.lsp.Client
---@param bufnr integer
---@return boolean
local function supports_rename(client, bufnr)
    return client:supports_method(ms.workspace_willRenameFiles, bufnr)
        or client:supports_method(ms.workspace_didRenameFiles, bufnr)
end

---@class pde.lsp
local M = {}

---@param client vim.lsp.Client
---@param bufnr integer
function M.attach(client, bufnr)
    for method, feature in pairs(features) do
        if client:supports_method(method, bufnr) then feature.attach(client, bufnr) end
    end

    if supports_rename(client, bufnr) then
        keymapper.set(bufnr, "grfn", require("pde.lsp.rename").rename_file, "Rename current file")
    end

    keymapper.set(bufnr, "grwa", vim.lsp.buf.add_workspace_folder, "Add Workspace Folder")
    keymapper.set(bufnr, "grwr", vim.lsp.buf.remove_workspace_folder, "Remove Workspace Folder")
    keymapper.set(
        bufnr,
        "grwl",
        function() vim.notify(vim.inspect(vim.lsp.buf.list_workspace_folders()), vim.log.levels.INFO) end,
        "List Workspace Folders"
    )
end

---@param client vim.lsp.Client
---@param bufnr integer
function M.detach(client, bufnr)
    -- detach runs just before the client leaves, so it is still in this list
    local others = vim.tbl_filter(function(c) return c.id ~= client.id end, vim.lsp.get_clients({ bufnr = bufnr }))

    ---@param supports fun(c: vim.lsp.Client): boolean
    local function is_last(supports) return supports(client) and not vim.iter(others):any(supports) end

    for method, feature in pairs(features) do
        local function supports(c) return c:supports_method(method, bufnr) end
        if (feature.per_client and supports(client)) or is_last(supports) then feature.detach(client, bufnr) end
    end

    if is_last(function(c) return supports_rename(c, bufnr) end) then keymapper.del(bufnr, "grfn") end

    if #others == 0 then keymapper.clear(bufnr) end
end

return M
