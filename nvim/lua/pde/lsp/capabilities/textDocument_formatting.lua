local format_is_enabled = true

---@type table<integer,integer>
---tracks which buffers have formatters attached
---want to avoid formatting via the wrong formatter
---and overlapping functionality
local buffer_to_client = {}

---@param clientid integer
---@param bufnr integer
local format = function(clientid, bufnr)
    vim.lsp.buf.format({
        async = false,
        id = clientid,
        bufnr = bufnr,
        timeout_ms = 2000,
    })
end

---@type CapabilityHandler
return {
    attach = function(data)
        local augroup = data.augroup
        local bufnr = data.bufnr
        local client = data.client

        local existing_client = buffer_to_client[bufnr]
        if existing_client and existing_client ~= client.id then
            vim.notify(
                "cannot format using client "
                    .. client.id
                    .. "; buffer "
                    .. bufnr
                    .. " already has formatting via client "
                    .. existing_client,
                vim.log.levels.ERROR
            )
            return
        end
        buffer_to_client[bufnr] = client.id

        vim.api.nvim_buf_create_user_command(bufnr, "AutoFormatToggle", function()
            format_is_enabled = not format_is_enabled
            print("Setting autoformatting to: " .. tostring(format_is_enabled))
        end, {
            desc = "Enable/disable autoformat with lsp globally",
        })

        vim.api.nvim_create_autocmd("BufWritePre", {
            desc = "AutoFormat on save by " .. client.name,
            group = augroup,
            buffer = bufnr,
            callback = function(args)
                if not format_is_enabled then return end
                format(client.id, args.buf)
            end,
        })

        vim.api.nvim_buf_create_user_command(
            bufnr,
            "Format",
            function() format(client.id, bufnr) end,
            { desc = "Format current buffer with " .. client.name }
        )
    end,

    detach = function(_, bufnr)
        vim.api.nvim_buf_del_user_command(bufnr, "AutoFormatToggle")
        vim.api.nvim_buf_del_user_command(bufnr, "Format")
        buffer_to_client[bufnr] = nil
    end,
}
