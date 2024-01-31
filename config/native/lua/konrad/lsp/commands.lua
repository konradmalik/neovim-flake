local lsp = require("konrad.lsp")
local popup = require("plenary.popup")

---@param args string
---@return number?
local function parse_int_arg(args)
    local arguments = vim.split(args, "%s")
    for _, v in pairs(arguments) do
        if v:find("^[0-9]+$") then return tonumber(v) end
    end
    return nil
end

---@param filter vim.lsp.get_clients.filter?
local function restart_servers(filter)
    local clients = vim.lsp.get_clients(filter)
    local detach_clients = {}
    for _, client in ipairs(clients) do
        detach_clients[client.id] = { client, client.attached_buffers }
        vim.lsp.stop_client(client.id)
    end

    local timer = vim.loop.new_timer()
    timer:start(
        500,
        100,
        vim.schedule_wrap(function()
            for old_client_id, tuple in pairs(detach_clients) do
                local client, attached_buffers = unpack(tuple)
                if client.is_stopped() then
                    for buf in pairs(attached_buffers) do
                        lsp.start_and_attach(client.config, buf)
                    end
                    detach_clients[old_client_id] = nil
                end
            end

            if next(detach_clients) == nil and not timer:is_closing() then timer:close() end
        end)
    )
end

---@param config table?
---@return table
local function create_window(config)
    config = config or {}
    local width = config.width or 100
    local height = config.height or 40
    local borderchars = config.borderchars
        or { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
    local bufnr = vim.api.nvim_create_buf(false, true)

    local win_id, _ = popup.create(bufnr, {
        title = "LspInfo",
        line = math.floor(((vim.o.lines - height) / 2) - 1),
        col = math.floor((vim.o.columns - width) / 2),
        minwidth = width,
        minheight = height,
        borderchars = borderchars,
    })

    return {
        bufnr = bufnr,
        win_id = win_id,
    }
end

vim.api.nvim_create_user_command("LspInfo", function()
    local replacement = {}
    for i, client in ipairs(vim.lsp.get_clients()) do
        if i > 1 then table.insert(replacement, "---------------") end
        table.insert(replacement, string.format("Client: %s (%s)", client.name, client.id))
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
    local info = create_window()
    vim.api.nvim_buf_set_lines(info.bufnr, 0, 0, false, replacement)
    vim.api.nvim_set_option_value("readonly", true, { buf = info.bufnr })
end, {
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
    local server_id = parse_int_arg(info.args)
    if server_id then
        vim.notify("detaching server with id: " .. server_id .. " from the current buf")
        vim.lsp.buf_detach_client(0, server_id)
    else
        vim.notify("detaching all lsp servers from the current buf")
        local bufnr = vim.api.nvim_get_current_buf()
        for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
            vim.lsp.buf_detach_client(0, client.id)
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
