local mini_icons = require("mini.icons")
local docs_debounce_ms = 250
local docs_timer = assert(vim.uv.new_timer(), "cannot create timer")
local trigger_debounce_ms = 250
local trigger_timer = assert(vim.uv.new_timer(), "cannot create timer")
-- some LSPs for some reason say they have completionItem_resolve capability
-- but then throw errors when this is executed (I look at you gopls)
local documentation_is_enabled = true
local ms = vim.lsp.protocol.Methods

local initialized = false
local function initialize_once()
    if initialized then return end
    mini_icons.tweak_lsp_kind("replace")
    initialized = true
end

---@return boolean
local function pumvisible() return tonumber(vim.fn.pumvisible()) ~= 0 end

---@param docs string
---@param client vim.lsp.Client
---@return string
local function format_docs(docs, client) return docs .. "\n\n_source: " .. client.name .. "_" end

---@param keys string
local function feedkeys(keys)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", false)
end

---@param client vim.lsp.Client
---@param bufnr integer
---@param opts vim.lsp.completion.BufferOpts?
local function enable(client, bufnr, opts)
    initialize_once()

    opts = opts or { autotrigger = false }
    vim.lsp.completion.enable(true, client.id, bufnr, opts)

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

    -- completion is triggered only on inserting new characters,
    -- if we delete char to adjust the match, popup disappears
    -- this solves it
    for _, keys in ipairs({ "<BS>", "<C-h>", "<C-w>" }) do
        keymap("i", keys, function()
            if pumvisible() then
                trigger_timer:stop()
                feedkeys(keys)
                trigger_timer:start(
                    trigger_debounce_ms,
                    0,
                    vim.schedule_wrap(vim.lsp.completion.trigger)
                )
                return
            end
            feedkeys(keys)
        end, "Feed '" .. keys .. "' and trigger LSP completion if needed")
    end
end

---@param selected_index integer
---@param result table
---@param client vim.lsp.Client
local function show_documentation(selected_index, result, client)
    local docs = vim.tbl_get(result, "documentation", "value")
    if not docs then return end

    local wininfo = vim.api.nvim__complete_set(selected_index, { info = format_docs(docs, client) })
    if vim.tbl_isempty(wininfo) or not vim.api.nvim_win_is_valid(wininfo.winid) then return end

    vim.wo[wininfo.winid].conceallevel = 2
    vim.wo[wininfo.winid].concealcursor = "n"

    if not vim.api.nvim_buf_is_valid(wininfo.bufnr) then return end

    vim.bo[wininfo.bufnr].syntax = "markdown"
    vim.treesitter.start(wininfo.bufnr, "markdown")
end

---@param client vim.lsp.Client
---@param augroup integer
---@param bufnr integer
local function enable_completion_documentation(client, augroup, bufnr)
    vim.api.nvim_create_autocmd("CompleteChanged", {
        group = augroup,
        buffer = bufnr,
        callback = function()
            if not documentation_is_enabled then return end

            docs_timer:stop()

            local client_id =
                vim.tbl_get(vim.v.completed_item, "user_data", "nvim", "lsp", "client_id")
            if client_id ~= client.id then return end

            local completion_item =
                vim.tbl_get(vim.v.completed_item, "user_data", "nvim", "lsp", "completion_item")
            if not completion_item then return end

            local complete_info = vim.fn.complete_info({ "selected" })
            if vim.tbl_isempty(complete_info) then return end

            local selected_index = complete_info.selected

            docs_timer:start(
                docs_debounce_ms,
                0,
                vim.schedule_wrap(function()
                    client:request(ms.completionItem_resolve, completion_item, function(err, result)
                        if err ~= nil then
                            vim.notify(
                                "Error from client "
                                    .. client.id
                                    .. " when getting documentation\n"
                                    .. vim.inspect(err),
                                vim.log.levels.WARN
                            )
                            -- at this stage just disable it
                            documentation_is_enabled = false
                            return
                        end

                        show_documentation(selected_index, result, client)
                    end, bufnr)
                end)
            )
        end,
    })
end

---@type CapabilityHandler
return {
    attach = function(data)
        local augroup = data.augroup
        local bufnr = data.bufnr
        local client = data.client

        enable(client, bufnr, { autotrigger = false })

        if client:supports_method(ms.completionItem_resolve, bufnr) then
            enable_completion_documentation(client, augroup, bufnr)
        end
    end,

    detach = function(client_id, bufnr) vim.lsp.completion.enable(false, client_id, bufnr) end,
}
