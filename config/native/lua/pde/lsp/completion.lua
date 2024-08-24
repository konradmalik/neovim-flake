local M = {}

---@param client vim.lsp.Client
---@param augroup integer
---@param bufnr integer
M.enable_completion_documentation = function(client, augroup, bufnr)
    vim.api.nvim_create_autocmd("CompleteChanged", {
        group = augroup,
        buffer = bufnr,
        callback = function()
            local client_id =
                vim.tbl_get(vim.v.completed_item, "user_data", "nvim", "lsp", "client_id")
            if client_id ~= client.id then return end

            local completion_item =
                vim.tbl_get(vim.v.completed_item, "user_data", "nvim", "lsp", "completion_item")
            if not completion_item then return end

            client.request(
                vim.lsp.protocol.Methods.completionItem_resolve,
                completion_item,
                ---@param err lsp.ResponseError
                ---@param result any
                function(err, result)
                    if err ~= nil then
                        vim.notify(vim.inspect(err), vim.log.levels.ERROR)
                        return
                    end

                    local info = vim.fn.complete_info({ "selected" })
                    if vim.tbl_isempty(info) then return end

                    local docs = vim.tbl_get(result, "documentation", "value")
                    if not docs then return end

                    local wininfo = vim.api.nvim__complete_set(info.selected, { info = docs })
                    if vim.tbl_isempty(wininfo) or not vim.api.nvim_win_is_valid(wininfo.winid) then
                        return
                    end

                    vim.api.nvim_win_set_config(wininfo.winid, { border = "rounded" })
                    vim.wo[wininfo.winid].conceallevel = 2
                    vim.wo[wininfo.winid].concealcursor = "niv"

                    if not vim.api.nvim_buf_is_valid(wininfo.bufnr) then return end

                    vim.bo[wininfo.bufnr].syntax = "markdown"
                    vim.treesitter.start(wininfo.bufnr, "markdown")
                end,
                bufnr
            )
        end,
    })
end

---@param client vim.lsp.Client
---@param bufnr integer
M.enable = function(client, bufnr)
    vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
end

return M
