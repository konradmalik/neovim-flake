local ms = vim.lsp.protocol.Methods
local lsp = require("pde.lsp")

require("pde.loader").add_to_on_reset(
    function() vim.fs.rm(vim.lsp.log.get_filename(), { force = true }) end
)

vim.lsp.config("*", { capabilities = lsp.make_capabilities() })
vim.lsp.enable({
    "clangd",
    "golangci_lint_ls",
    "gopls",
    "gopls",
    "harper_ls",
    "json_fl",
    "jsonls",
    "lua_ls",
    "marksman",
    "nixd",
    "prettier",
    "py_fl",
    "roslyn_ls",
    "rust_analyzer",
    "sh",
    "stylua",
    "taplo",
    "terraformls",
    "ty",
    "yamlls",
    "zls",
})

---@param args string
---@return number?
local function parse_int_arg(args)
    local arguments = vim.split(args, "%s")
    for _, v in pairs(arguments) do
        if v:find("^[0-9]+$") then return tonumber(v) end
    end
    return nil
end

vim.lsp.log.set_level(vim.log.levels.WARN)

---@type lsp.Handler
vim.lsp.handlers[ms.workspace_diagnostic_refresh] = function(_, _, ctx)
    local ns = vim.lsp.diagnostic.get_namespace(ctx.client_id)
    pcall(vim.diagnostic.reset, ns)
    return true
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

local group = vim.api.nvim_create_augroup("personal-lsp", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
    group = group,
    callback = function(args)
        local client_id = args.data.client_id
        local client = vim.lsp.get_client_by_id(client_id)
        if client then
            lsp.attach(client, args.buf)
        else
            vim.notify("cannot find client " .. client_id, vim.log.levels.ERROR)
        end
    end,
})

vim.api.nvim_create_autocmd("LspDetach", {
    group = group,
    callback = function(args)
        local client_id = args.data.client_id
        local client = vim.lsp.get_client_by_id(client_id)
        if client then
            lsp.detach(client, args.buf)
        else
            vim.notify("cannot find client " .. client_id, vim.log.levels.ERROR)
        end
    end,
})
