local mini_icons = require("mini.icons")
-- some LSPs for some reason say they have completionItem_resolve capability
-- but then throw errors when this is executed (I look at you gopls)
---@type table<integer, boolean>

---@type table<integer,string>
local kind_map = {}

local initialized = false
local function initialize_once()
    if initialized then return end

    mini_icons.tweak_lsp_kind("replace")
    for k, v in pairs(vim.lsp.protocol.CompletionItemKind) do
        if type(k) == "string" and type(v) == "number" then kind_map[v] = k end
    end

    initialized = true
end

---@param item lsp.CompletionItem
---@return boolean
local function is_deprecated(item)
    return item.deprecated
        or vim.list_contains(item.tags or {}, vim.lsp.protocol.CompletionTag.Deprecated)
end

---@type CapabilityHandler
return {
    attach = function(data)
        local bufnr = data.bufnr
        local client = data.client

        initialize_once()

        local autotrigger = not vim.bo[bufnr].autocomplete
        -- NOTE: what is this, compared to just vim.bo.autocomplete with omnifunc (that is already set without the below line)?
        -- This enables autocommands to apply sideeffects like additionalTextEdits, snippet expansions, commands etc. on selecting completion item
        -- Those then apply to omnifunc as well because events are triggered regardless.
        vim.lsp.completion.enable(true, client.id, bufnr, {
            autotrigger = autotrigger,
            convert = function(item)
                local _, kind_hl, _ = mini_icons.get("lsp", kind_map[item.kind] or "Unknown")
                return {
                    abbr_hlgroup = is_deprecated(item) and "@lsp.mod.deprecated" or kind_hl,
                    kind_hlgroup = kind_hl or nil,
                }
            end,
        })
    end,

    detach = function(client_id, bufnr) vim.lsp.completion.enable(false, client_id, bufnr) end,
}
