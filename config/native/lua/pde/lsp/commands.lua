local lsp = require("pde.lsp")

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
        client.stop()
    end

    local timer = vim.uv.new_timer()
    if not timer then error("cannot create timer", vim.log.levels.ERROR) end
    timer:start(
        500,
        100,
        vim.schedule_wrap(function()
            for old_client_id, tuple in pairs(detach_clients) do
                local client = tuple[1]
                local attached_buffers = tuple[2]
                if client.is_stopped() then
                    for _, buf in ipairs(attached_buffers) do
                        lsp.start(client.config, { bufnr = buf })
                    end
                    detach_clients[old_client_id] = nil
                end
            end

            if next(detach_clients) == nil and not timer:is_closing() then timer:close() end
        end)
    )
end

---@param title string
---@return table
local function create_window(title)
    local width = 100
    local height = 40

    local bufnr = vim.api.nvim_create_buf(false, true)
    local win_id = vim.api.nvim_open_win(bufnr, true, {
        title = title,
        relative = "editor",
        row = math.floor(((vim.o.lines - height) / 2) - 1),
        col = math.floor((vim.o.columns - width) / 2),
        width = width,
        height = height,
        border = "rounded",
        style = "minimal",
        noautocmd = true,
    })

    vim.api.nvim_set_option_value("winfixbuf", true, { win = win_id })

    return {
        bufnr = bufnr,
        win_id = win_id,
    }
end

local function lsp_info()
    local replacement = {}
    for i, client in ipairs(vim.lsp.get_clients()) do
        if i > 1 then table.insert(replacement, "---------------") end
        table.insert(replacement, string.format("Client: %s (id: %s)", client.name, client.id))
        table.insert(replacement, string.format("Root Dir: %s", client.config.root_dir))
        local cmd_str
        if type(client.config.cmd) == "function" then
            cmd_str = "fun(dispatchers)"
        else
            cmd_str = table.concat(client.config.cmd, " ")
        end
        table.insert(replacement, cmd_str)
        table.insert(
            replacement,
            string.format(
                "Attached Bufs: [ %s ]",
                table.concat(vim.tbl_keys(client.attached_buffers), ", ")
            )
        )
    end
    local info = create_window("LspInfo")
    vim.api.nvim_buf_set_lines(info.bufnr, 0, 0, false, replacement)
    vim.api.nvim_set_option_value("readonly", true, { buf = info.bufnr })
end

vim.api.nvim_create_user_command("LspInfo", lsp_info, {
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

vim.api.nvim_create_user_command("LspAutostartToggle", function()
    lsp.toggle_autostart()
    print("Setting lsp autostart to: " .. tostring(lsp.is_autostart_enabled()))
end, {
    desc = "Disables autostart of all LSPs",
})
