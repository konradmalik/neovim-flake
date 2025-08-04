local ms = vim.lsp.protocol.Methods

---@type table<string,fun(params: table?, callback: fun(err?: lsp.ResponseError, result: any), notify_reply_callback?: fun(message_id: integer)):boolean, integer?>
local handlers = {
    [ms.initialize] = function(params, callback, notify_reply_callback)
        ---@type lsp.InitializeParams
        local initializeResult = {
            capabilities = {
                completionProvider = {
                    triggerCharacters = { "." },
                },
            },
            serverInfo = {
                name = "testlsp",
                version = "0.0.1",
            },
            rootUri = vim.NIL,
            processId = vim.NIL,
        }

        callback(nil, initializeResult)
        return true
    end,

    [ms.textDocument_completion] = function(request, callback, _)
        local response = {}
        callback(nil, response)
        return true
    end,
}

---@return vim.lsp.ClientConfig
local function get_lsp_config()
    return {
        name = "testlsp",
        ---@param dispatchers vim.lsp.rpc.Dispatchers
        ---@param config vim.lsp.ClientConfig
        ---@return vim.lsp.rpc.PublicClient
        cmd = function(dispatchers, config)
            ---@type vim.lsp.rpc.PublicClient
            local members = {
                request = function(method, params, callback, notify_reply_callback)
                    if handlers[method] then
                        handlers[method](params, callback, notify_reply_callback)
                        return true
                    end
                    return false
                end,
                notify = function(method, params) return true end,
                is_closing = function() return false end,
                terminate = function() end,
            }
            return members
        end,
        filetypes = { "*" },
        root_dir = vim.fn.getcwd(),
    }
end

vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function(event) vim.lsp.start(get_lsp_config(), { bufnr = event.buf }) end,
})
