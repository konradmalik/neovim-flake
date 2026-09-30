---@type table<integer,integer>
---tracks which buffers have formatters attached
---want to avoid formatting via the wrong formatter
---and overlapping functionality
local buffer_to_client = {}

---@type pde.lsp.Feature
return {
    per_client = true,

    attach = function(client, bufnr)
        local existing_client = buffer_to_client[bufnr]
        if existing_client and existing_client ~= client.id then
            vim.notify(
                "cannot enable formatting using client "
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
    end,

    detach = function(client, bufnr)
        -- a rejected client leaving must not drop the actual owner
        if buffer_to_client[bufnr] == client.id then buffer_to_client[bufnr] = nil end
    end,
}
