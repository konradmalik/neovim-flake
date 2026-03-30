local utils = require("pde.statusline.utils")

local M = {}

--- Creates an event-cached statusline component.
--- The component function is called once per buffer and its result is cached.
--- The cache is invalidated when any of the specified events fire.
---
--- @generic F: fun(...): string
--- @param component F
--- @param spec {events: string|string[], buffer?: boolean}
---        Autocmd specs that invalidate the cache.
---        When `buffer` is true, only the affected buffer's cache entry is cleared.
---        When `buffer` is false (default), the entire cache is cleared.
--- @return F
function M.create(component, spec)
    ---@type table<integer, string>
    local cache = {}

    local group = vim.api.nvim_create_augroup("StCached_" .. tostring(component), { clear = true })

    vim.api.nvim_create_autocmd(spec.events, {
        group = group,
        callback = function(ev)
            if spec.buffer == true and ev.buf then
                cache[ev.buf] = nil
            else
                for k in pairs(cache) do
                    cache[k] = nil
                end
            end
        end,
        desc = "invalidate cached statusline component '" .. tostring(component) .. "'",
    })

    return function(args)
        local bufnr = utils.stbufnr()
        local result = cache[bufnr]
        if result ~= nil then return result end
        result = component(args)
        cache[bufnr] = result
        return result
    end
end

return M
