---@class pde.statusline.cache
local M = {}

local global_cache_key = -1

--- Creates an event-cached statusline component.
--- The component function is called once per buffer and its result is cached.
--- The cache is invalidated when any of the specified events fire, followed by a redrawstatus.
---
--- @generic F: fun(bufnr: integer, ...): string
--- @param component F
--- @param spec {events: string[], buffer?: boolean}
---        Autocmd events that invalidate the cache.
---        When `buffer` is true, the cache is created separately per buffer.
---        When `buffer` is false (default), the cache is global for all buffers.
--- @return F
function M.create(component, spec)
    ---@type table<integer, string>
    local cache = {}

    local group = vim.api.nvim_create_augroup("StCached_" .. tostring(component), { clear = true })
    local desc = "invalidate cached statusline component '" .. tostring(component) .. "'"

    vim.api.nvim_create_autocmd(spec.events, {
        group = group,
        callback = function(ev)
            -- schedule avoids race condition by running only after other events stopped processing
            vim.schedule(function()
                cache[spec.buffer and ev.buf or global_cache_key] = nil
                vim.cmd.redrawstatus()
            end)
        end,
        desc = desc,
    })

    if spec.buffer then
        vim.api.nvim_create_autocmd("BufDelete", {
            group = group,
            callback = function(ev) cache[ev.buf] = nil end,
            desc = "clear cache for deleted buffer for '" .. tostring(component) .. "'",
        })
    end

    return function(bufnr, ...)
        local cache_key = spec.buffer and bufnr or global_cache_key

        local result = cache[cache_key]
        if result ~= nil then return result end

        result = component(bufnr, ...)
        cache[cache_key] = result
        return result
    end
end

return M
