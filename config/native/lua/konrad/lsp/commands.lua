local popup = require("plenary.popup")

local function create_window()
    local config = {}
    local width = config.width or 100
    local height = config.height or 40
    local borderchars = config.borderchars or { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
    local bufnr = vim.api.nvim_create_buf(false, true)

    local win_id, win = popup.create(bufnr, {
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
        local name = client.name
        local cmd = table.concat(client.config.cmd, ",")
        local root_dir = client.config.root_dir
        local buffers = table.concat(vim.tbl_keys(client.attached_buffers), ",")
        replacement[i] = string.format(
            "id: %s, name: %s, cmd: %s, root_dir: %s, buffers: %s",
            client.id,
            name,
            cmd,
            root_dir,
            buffers
        )
    end
    local info = create_window()
    vim.api.nvim_buf_set_lines(info.bufnr, 0, 0, false, replacement)
    vim.api.nvim_set_option_value("readonly", true, { buf = info.bufnr })
end, {
    desc = "List LSP clients with their details",
})

vim.api.nvim_create_user_command("LspStop", function(info)
    local server_id
    local arguments = vim.split(info.args, "%s")
    for _, v in pairs(arguments) do
        if v:find("^[0-9]+$") then
            server_id = tonumber(v)
        end
    end
    if server_id then
        vim.notify("stoping server with id: " .. server_id)
        vim.lsp.stop_client(server_id)
    else
        vim.notify("stoping all lsp servers")
        vim.lsp.stop_client(vim.lsp.get_clients())
    end
end, {
    desc = "Stops specified LSP by id",
    nargs = 1,
})
