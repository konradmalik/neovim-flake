local mini_icons = require("mini.icons")
local trigger_debounce_ms = 250
local trigger_timer = assert(vim.uv.new_timer(), "cannot create timer")
-- some LSPs for some reason say they have completionItem_resolve capability
-- but then throw errors when this is executed (I look at you gopls)
---@type table<integer, boolean>
local documentation_is_disabled = {}
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
---@param client string
---@return string
local function format_docs(docs, client) return docs .. "\n\n_client: " .. client .. "_" end

---@param keys string
local function feedkeys(keys)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", false)
end

---@param bufnr integer
---@return boolean
local function is_popup_enabled(bufnr)
    local options = vim.bo[bufnr].completeopt
    if options == "" then options = vim.o.completeopt end
    return options:find("popup") ~= nil
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

---@param selected_index integer
---@param lsp_documentation string|lsp.MarkupContent
---@param client string
local function set_documetation(selected_index, lsp_documentation, client)
    local kind = lsp_documentation and lsp_documentation.kind
    local filetype = kind == "markdown" and "markdown" or ""
    local documentation_value = type(lsp_documentation) == "string" and lsp_documentation
        or lsp_documentation.value

    local wininfo = vim.api.nvim__complete_set(
        selected_index,
        { info = format_docs(documentation_value, client) }
    )
    if vim.tbl_isempty(wininfo) or not vim.api.nvim_win_is_valid(wininfo.winid) then return end

    vim.wo[wininfo.winid].conceallevel = 2
    vim.wo[wininfo.winid].concealcursor = "n"
    vim.api.nvim_win_set_config(wininfo.winid, {
        border = vim.o.winborder,
    })

    if not vim.api.nvim_buf_is_valid(wininfo.bufnr) then return end

    vim.bo[wininfo.bufnr].filetype = filetype
    if filetype ~= "" then vim.treesitter.start(wininfo.bufnr) end
end

---@class CompleteInfo
---@field selected integer Index of selected completion entry

---@param client vim.lsp.Client
---@param augroup integer
---@param bufnr integer
local function enable_completion_documentation(client, augroup, bufnr)
    local _, req_id = nil, nil

    vim.api.nvim_create_autocmd("CompleteChanged", {
        group = augroup,
        buffer = bufnr,
        callback = function()
            if req_id then client:cancel_request(req_id) end

            if documentation_is_disabled[client.id] or not pumvisible() then return end
            local completed_item = vim.v.completed_item

            local client_id = vim.tbl_get(completed_item, "user_data", "nvim", "lsp", "client_id")
            if client_id ~= client.id then return end

            ---@type lsp.CompletionItem
            local lsp_completion_item =
                vim.tbl_get(completed_item, "user_data", "nvim", "lsp", "completion_item")
            if not lsp_completion_item or lsp_completion_item.documentation then return end

            ---@type CompleteInfo
            local complete_info = vim.fn.complete_info({ "selected" })
            if vim.tbl_isempty(complete_info) then return end

            _, req_id = client:request(
                ms.completionItem_resolve,
                lsp_completion_item,
                ---@param err lsp.ResponseError
                ---@param resolved_item lsp.CompletionItem
                function(err, resolved_item)
                    if err ~= nil then
                        vim.notify(
                            "Error from client "
                                .. client.name
                                .. " when getting documentation\n"
                                .. vim.inspect(err),
                            vim.log.levels.WARN
                        )
                        -- at this stage just disable it
                        documentation_is_disabled[client.id] = true
                        return
                    end
                    if not resolved_item or not resolved_item.documentation then return end

                    set_documetation(
                        complete_info.selected,
                        resolved_item.documentation,
                        client.name
                    )
                end,
                bufnr
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

        initialize_once()

        local autotrigger = not vim.bo[bufnr].autocomplete
        vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = autotrigger })
        if autotrigger then trigger_on_delete(bufnr) end

        if is_popup_enabled(bufnr) and client:supports_method(ms.completionItem_resolve, bufnr) then
            enable_completion_documentation(client, augroup, bufnr)
        end
    end,

    detach = function(client_id, bufnr) vim.lsp.completion.enable(false, client_id, bufnr) end,
}
