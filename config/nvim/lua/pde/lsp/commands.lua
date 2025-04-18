---@param args string
---@return number?
local function parse_int_arg(args)
    local arguments = vim.split(args, "%s")
    for _, v in pairs(arguments) do
        if v:find("^[0-9]+$") then return tonumber(v) end
    end
    return nil
end

---@param filter vim.lsp.get_clients.Filter?
local function restart_servers(filter)
    local clients = vim.lsp.get_clients(filter)
    ---@type table<integer, {[1]: vim.lsp.Client, [2]: integer[]}>
    local detach_clients = {}
    for _, client in ipairs(clients) do
        detach_clients[client.id] = { client, vim.lsp.get_buffers_by_client_id(client.id) }
        client:stop()
    end

    local timer = assert(vim.uv.new_timer(), "cannot create timer")
    timer:start(
        500,
        100,
        vim.schedule_wrap(function()
            for old_client_id, tuple in pairs(detach_clients) do
                local client = tuple[1]
                local attached_buffers = tuple[2]
                if client:is_stopped() then
                    for _, buf in ipairs(attached_buffers) do
                        vim.lsp.start(client.config, { bufnr = buf })
                    end
                    detach_clients[old_client_id] = nil
                end
            end

            if next(detach_clients) == nil and not timer:is_closing() then timer:close() end
        end)
    )
end

vim.api.nvim_create_user_command("LspInfo", "checkhealth lsp", {
    desc = "List LSP clients with their details",
})

vim.api.nvim_create_user_command("LspStop", function(info)
    local server_id = parse_int_arg(info.args)
    if server_id then
        vim.notify("stoping server with id: " .. server_id)
        vim.lsp.stop_client(server_id)
    else
        vim.notify("stoping all lsp servers")
        vim.lsp.stop_client(vim.lsp.get_clients())
    end
end, {
    desc = "Stops specified LSP by id",
    nargs = "?",
})

vim.api.nvim_create_user_command("LspDetach", function(info)
    local bufnr = vim.api.nvim_get_current_buf()
    local server_id = parse_int_arg(info.args)
    if server_id then
        vim.notify("detaching server with id: " .. server_id .. " from the current buf")
        vim.lsp.buf_detach_client(bufnr, server_id)
    else
        vim.notify("detaching all lsp servers from the current buf")
        for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
            vim.lsp.buf_detach_client(bufnr, client.id)
        end
    end
end, {
    desc = "Stops specified LSP by id",
    nargs = "?",
})

vim.api.nvim_create_user_command("LspRestart", function(info)
    local server_id = parse_int_arg(info.args)
    if server_id then
        vim.notify("restarting server with id: " .. server_id)
        restart_servers({ id = server_id })
    else
        vim.notify("restarting all lsp servers")
        restart_servers()
    end
end, {
    desc = "Restarts specified LSPs by id",
    nargs = "?",
})

vim.api.nvim_create_user_command(
    "LspLog",
    function() vim.cmd(string.format("tabnew %s", vim.lsp.get_log_path())) end,
    {
        desc = "Opens the Nvim LSP client log.",
    }
)
