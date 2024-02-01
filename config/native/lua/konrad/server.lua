-- luacheck: ignore
-- https://zignar.net/2022/10/26/testing-neovim-lsp-plugins/#a-in-process-lsp-server
-- A server implementation is just a function that returns a table with several methods
-- `dispatchers` is a table with a couple methods that allow the server to interact with the client
---@param dispatchers vim.lsp.rpc.Dispatchers
local function server(dispatchers)
    local closing = false
    local srv = {}

    -- This method is called each time the client makes a request to the server
    -- `method` is the LSP method name
    -- `params` is the payload that the client sends
    -- `callback` is a function which takes two parameters: `err` and `result`
    -- The callback must be called to send a response to the client
    -- To learn more about what method names are available and the structure of
    -- the payloads you'll need to read the specification:
    -- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/
    ---@param method string of vim.lsp.protocol.Methods
    ---@param params table<string,any> see types like lsp.CodeLensParams
    function srv.request(method, params, callback)
        if method == "initialize" then
            callback(nil, { capabilities = {} })
        elseif method == "shutdown" then
            callback(nil, nil)
        end
        return true, 1
    end

    -- This method is called each time the client sends a notification to the server
    -- The difference between `request` and `notify` is that notifications don't expect a response
    ---@param method string see vim.lsp.protocol.Methods
    ---@param params table<string,any> see types like lsp.CodeLensParams
    function srv.notify(method, params)
        if method == "exit" then dispatchers.on_exit(0, 15) end
    end

    -- Indicates if the client is shutting down
    function srv.is_closing() return closing end

    -- Callend when the client wants to terminate the process
    function srv.terminate() closing = true end

    return srv
end

-- vim.lsp.start_client({ name = "my-server", cmd = server })
