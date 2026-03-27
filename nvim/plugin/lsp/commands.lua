---@param args string
---@return number?
local function parse_int_arg(args)
    local arguments = vim.split(args, "%s")
    for _, v in pairs(arguments) do
        if v:find("^[0-9]+$") then return tonumber(v) end
    end
    return nil
end

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

vim.api.nvim_create_user_command(
    "LspLog",
    function() vim.cmd(string.format("tabnew %s", vim.lsp.log.get_filename())) end,
    {
        desc = "Opens the Nvim LSP client log.",
    }
)
