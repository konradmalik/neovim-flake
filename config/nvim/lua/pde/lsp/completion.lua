local docs_debounce_ms = 250
local docs_timer = assert(vim.uv.new_timer(), "cannot create timer")
local trigger_debounce_ms = 250
local trigger_timer = assert(vim.uv.new_timer(), "cannot create timer")
-- some LSPs for some reason say they have completionItem_resolve capability
-- but then throw errors when this is executed (I look at you gopls)
local documentation_is_enabled = true

local kind_icons = {
    Constructor = "",
    Function = "󰊕",
    Method = "󰊕",

    Field = "󰜢",
    Property = "󰖷",
    Variable = "󰆦",

    Class = "󰠱",
    Interface = "",
    Module = "",
    Namespace = "",
    Object = "",
    Package = "",
    Struct = "󱡠",

    Enum = "",
    EnumMember = "",
    Unit = "󰑭",
    Value = "󰎠",

    Array = "",
    Boolean = "",
    Constant = "󰏿",
    Keyword = "󰻾",
    Null = "󰟢",
    Number = "",
    String = "",
    Text = "",

    Color = "󰏘",
    Event = "",
    File = "󰈙",
    Folder = "󰉋",
    Key = "",
    Operator = "󰆕",
    Reference = "",
    Snippet = "󱄽",
    TypeParameter = "",
}

local initialized = false
local function initialize_once()
    if initialized then return end
    for i, v in ipairs(vim.lsp.protocol.CompletionItemKind) do
        vim.lsp.protocol.CompletionItemKind[i] = kind_icons[v]
    end
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

local M = {}

M.kind_icons = kind_icons

---@param client vim.lsp.Client
---@param bufnr integer
---@param opts vim.lsp.completion.BufferOpts?
M.enable = function(client, bufnr, opts)
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

---@param client vim.lsp.Client
---@param augroup integer
---@param bufnr integer
M.enable_completion_documentation = function(client, augroup, bufnr)
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

            docs_timer:start(
                docs_debounce_ms,
                0,
                vim.schedule_wrap(function()
                    client:request(
                        vim.lsp.protocol.Methods.completionItem_resolve,
                        completion_item,
                        ---@param err lsp.ResponseError
                        ---@param result any
                        function(err, result)
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

                            local docs = vim.tbl_get(result, "documentation", "value")
                            if not docs then return end

                            local wininfo = vim.api.nvim__complete_set(
                                complete_info.selected,
                                { info = format_docs(docs, client) }
                            )
                            if
                                vim.tbl_isempty(wininfo)
                                or not vim.api.nvim_win_is_valid(wininfo.winid)
                            then
                                return
                            end

                            vim.api.nvim_win_set_config(wininfo.winid, { border = "rounded" })
                            vim.wo[wininfo.winid].conceallevel = 2
                            vim.wo[wininfo.winid].concealcursor = "n"

                            if not vim.api.nvim_buf_is_valid(wininfo.bufnr) then return end

                            vim.bo[wininfo.bufnr].syntax = "markdown"
                            vim.treesitter.start(wininfo.bufnr, "markdown")
                        end,
                        bufnr
                    )
                end)
            )
        end,
    })
end
return M
