---@type table<integer,integer>
---tracks which buffers have formatters attached
---want to avoid formatting via the wrong formatter
---and overlapping functionality
local buffer_to_client = {}

---@type CapabilityHandler
return {
    attach = function(data)
        local bufnr = data.bufnr
        local client = data.client

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

    detach = function(_, bufnr) buffer_to_client[bufnr] = nil end,
}
