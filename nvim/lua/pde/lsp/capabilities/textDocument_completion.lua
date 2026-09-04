local mini_icons = require("mini.icons")

---@type table<integer,string>
local kind_map = {}

local initialized = false
local function initialize_once()
    if initialized then return end

    mini_icons.tweak_lsp_kind("replace")

    for k, v in pairs(vim.lsp.protocol.CompletionItemKind) do
        if type(k) == "string" and type(v) == "number" then kind_map[v] = k end
    end

    -- HACK: add default border to documentation popup
    -- https://github.com/neovim/neovim/issues/38248
    local orig_complete_set = vim.api.nvim__complete_set
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.api.nvim__complete_set = function(...)
        local result = orig_complete_set(...)
        if result and result.winid then
            pcall(vim.api.nvim_win_set_config, result.winid, { border = vim.o.winborder })
        end
        return result
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
                local kind_category = kind_map[item.kind] or "Unknown"
                local _, kind_hl, _ = mini_icons.get("lsp", kind_category)
                ---@type vim.v.completed_item
                return {
                    abbr_hlgroup = is_deprecated(item) and "@lsp.mod.deprecated" or kind_hl,
                    kind_hlgroup = kind_hl or nil,
                }
            end,
        })
    end,

    detach = function(client_id, bufnr) vim.lsp.completion.enable(false, client_id, bufnr) end,
}
