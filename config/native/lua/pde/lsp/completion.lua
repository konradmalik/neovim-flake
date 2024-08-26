local docs_debounce_ms = 500
local timer = vim.uv.new_timer()

local kinds = {
    Text = "󰉿",
    Method = "󰆧",
    Function = "󰊕",
    Constructor = "",
    Field = "󰜢",
    Variable = "󰀫",
    Class = "󰠱",
    Interface = "",
    Module = "",
    Property = "󰜢",
    Unit = "󰑭",
    Value = "󰎠",
    Enum = "",
    Keyword = "󰌋",
    Snippet = "",
    Color = "󰏘",
    File = "󰈙",
    Reference = "󰈇",
    Folder = "󰉋",
    EnumMember = "",
    Constant = "󰏿",
    Struct = "󰙅",
    Event = "",
    Operator = "󰆕",
    TypeParameter = "",
}

local initialized = false
local function initialize_once()
    if initialized then return end
    for i, v in ipairs(vim.lsp.protocol.CompletionItemKind) do
        vim.lsp.protocol.CompletionItemKind[i] = kinds[v]
    end
    initialized = true
end

local function pumvisible() return tonumber(vim.fn.pumvisible()) ~= 0 end

---@param keys string
local function feedkeys(keys)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", true)
end

local M = {}

---@param client vim.lsp.Client
---@param bufnr integer
M.enable = function(client, bufnr)
    initialize_once()
    vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })

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
    for _, keys in ipairs({ "<BS>", "<C-h>" }) do
        keymap("i", keys, function()
            if pumvisible() then
                feedkeys(keys)
                vim.lsp.completion.trigger()
                return
            end
            feedkeys(keys)
        end, "Remove previous character and trigger LSP completion if needed")
    end

    -- Trigger LSP completion.
    -- If there's none, fallback to vanilla omnifunc.
    -- if there's none, use buffer completion
    keymap("i", "<C-Space>", function()
        if next(vim.lsp.get_clients({ bufnr = bufnr })) then
            vim.lsp.completion.trigger()
        else
            if vim.bo.omnifunc == "" then
                feedkeys("<C-x><C-n>")
            else
                feedkeys("<C-x><C-o>")
            end
        end
    end, "Smart completion trigger")
end

---@param client vim.lsp.Client
---@param augroup integer
---@param bufnr integer
M.enable_completion_documentation = function(client, augroup, bufnr)
    if not timer then
        vim.notify("cannot create timer", vim.log.levels.ERROR)
        return {}
    end

    vim.api.nvim_create_autocmd("CompleteChanged", {
        group = augroup,
        buffer = bufnr,
        callback = function()
            timer:stop()

            local client_id =
                vim.tbl_get(vim.v.completed_item, "user_data", "nvim", "lsp", "client_id")
            if client_id ~= client.id then return end

            local completion_item =
                vim.tbl_get(vim.v.completed_item, "user_data", "nvim", "lsp", "completion_item")
            if not completion_item then return end

            local complete_info = vim.fn.complete_info({ "selected" })
            if vim.tbl_isempty(complete_info) then return end

            timer:start(
                docs_debounce_ms,
                0,
                vim.schedule_wrap(function()
                    client.request(
                        vim.lsp.protocol.Methods.completionItem_resolve,
                        completion_item,
                        ---@param err lsp.ResponseError
                        ---@param result any
                        function(err, result)
                            if err ~= nil then
                                vim.notify(
                                    "client " .. client.id .. vim.inspect(err),
                                    vim.log.levels.ERROR
                                )
                                return
                            end

                            local docs = vim.tbl_get(result, "documentation", "value")
                            if not docs then return end

                            local wininfo =
                                vim.api.nvim__complete_set(complete_info.selected, { info = docs })
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
