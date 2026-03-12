local mini_icons = require("mini.icons")
local trigger_debounce_ms = 250
local trigger_timer = assert(vim.uv.new_timer(), "cannot create timer")
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

---@return boolean
local function pumvisible() return tonumber(vim.fn.pumvisible()) ~= 0 end

---@param keys string
local function feedkeys(keys)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", false)
end

--- Completion is triggered only on inserting new characters,
--- if we delete char to adjust the match, popup disappears
--- this solves it
---@param bufnr integer
local function trigger_on_delete(bufnr)
    ---@param mode string|string[]
    ---@param lhs string
    ---@param rhs string|function
    ---@param desc string
    local function keymap(mode, lhs, rhs, desc)
        vim.keymap.set(
            mode,
            lhs,
            rhs,
            { desc = "[Completion] " .. desc, buffer = bufnr, expr = true }
        )
    end

    for _, keys in ipairs({ "<BS>", "<C-h>", "<C-w>" }) do
        keymap("i", keys, function()
            local in_context = pumvisible() or trigger_timer:get_due_in() > 0
            trigger_timer:stop()
            if in_context then
                feedkeys(keys)
                trigger_timer:start(
                    trigger_debounce_ms,
                    0,
                    vim.schedule_wrap(vim.lsp.completion.get)
                )
                return
            end
            feedkeys(keys)
        end, "Feed '" .. keys .. "' and trigger LSP completion if needed")
    end
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
        if autotrigger then trigger_on_delete(bufnr) end
    end,

    detach = function(client_id, bufnr) vim.lsp.completion.enable(false, client_id, bufnr) end,
}
