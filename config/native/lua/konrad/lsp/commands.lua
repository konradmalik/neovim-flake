vim.api.nvim_create_user_command("LspInfo", function()
    local data = {}
    for _, client in ipairs(vim.lsp.get_clients()) do
        data[tostring(client.id)] = {
            name = client.name,
            cmd = client.config.cmd,
            buffers = vim.tbl_keys(client.attached_buffers),
            root_dir = client.config.root_dir,
        }
    end

    vim.print(vim.inspect(data))
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
