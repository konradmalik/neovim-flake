local keymapper = require("pde.lsp.keymapper")

---@class pde.lsp.Feature
---@field attach fun(client: vim.lsp.Client, bufnr: integer)
---@field detach? fun(client: vim.lsp.Client, bufnr: integer) runs when the last client supporting the method leaves

---@alias pde.lsp.Toggle { enable: fun(enable?: boolean), is_enabled: fun(): boolean }

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

local document_highlight = require("pde.lsp.capabilities.textDocument_documentHighlight")
local folding = require("pde.lsp.capabilities.textDocument_foldingRange")

---@type table<vim.lsp.protocol.Method.ClientToServer, pde.lsp.Feature>
local features = {
    ["textDocument/completion"] = require("pde.lsp.capabilities.textDocument_completion"),
    ["textDocument/foldingRange"] = folding,

    ["textDocument/codeLens"] = map("grl", vim.lsp.codelens.run, "CodeLens run"),
    ["textDocument/declaration"] = map("grd", vim.lsp.buf.declaration, "Go To Declaration"),
    ["textDocument/definition"] = map("<c-]>", telescope("lsp_definitions"), "Go To Definition"),
    ["textDocument/documentSymbol"] = map("gO", telescope("lsp_document_symbols"), "Document Symbols"),
    ["textDocument/implementation"] = map("gri", telescope("lsp_implementations"), "Go To Implementation"),
    ["textDocument/references"] = map("grr", telescope("lsp_references"), "Go To References"),
    ["textDocument/signatureHelp"] = map("grs", vim.lsp.buf.signature_help, "Signature Help"),
    ["textDocument/typeDefinition"] = map("grt", telescope("lsp_type_definitions"), "Type Definition"),
    ["workspace/symbol"] = map("gwO", telescope("lsp_dynamic_workspace_symbols"), "Workspace Symbols"),
}

-- builtin features, all set explicitly so a changed default doesn't go unnoticed.
-- enabling without a bufnr is global and also applies to clients that attach later
-- reference counts are annoying most of the time, but sometimes I might want this
vim.lsp.codelens.enable(false)
vim.lsp.document_color.enable(true)
vim.lsp.inlay_hint.enable(false)
vim.lsp.inline_completion.enable(true)
vim.lsp.linked_editing_range.enable(true)
vim.lsp.on_type_formatting.enable(true)
vim.lsp.semantic_tokens.enable(true)

---@param cmd string
---@param name string
---@param mod pde.lsp.Toggle
local function toggle_cmd(cmd, name, mod)
    vim.api.nvim_create_user_command(cmd, function()
        mod.enable(not mod.is_enabled())
        vim.notify("Setting " .. name .. " to: " .. tostring(mod.is_enabled()), vim.log.levels.INFO)
    end, { desc = "Enable/disable " .. name .. " with lsp" })
end

toggle_cmd("CodeLensToggle", "codelens", vim.lsp.codelens)
toggle_cmd("InlayHintsToggle", "inlayhints", vim.lsp.inlay_hint)
toggle_cmd("DocumentHighlightToggle", "document highlight", document_highlight)
toggle_cmd("FoldingImportsToggle", "imports folding", folding.imports)

-- file rename needs either of two methods, so it lives outside the one-method features table
---@param client vim.lsp.Client
---@param bufnr integer
---@return boolean
local function supports_rename(client, bufnr)
    return client:supports_method("workspace/willRenameFiles", bufnr)
        or client:supports_method("workspace/didRenameFiles", bufnr)
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
        if feature.detach and is_last(supports) then feature.detach(client, bufnr) end
    end

    if is_last(function(c) return supports_rename(c, bufnr) end) then keymapper.del(bufnr, "grfn") end

    if #others == 0 then keymapper.clear(bufnr) end
end

return M
