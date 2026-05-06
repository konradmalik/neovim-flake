local M = {}

local global_cache_key = -1

--- Creates an event-cached statusline component.
--- The component function is called once per buffer and its result is cached.
--- The cache is invalidated when any of the specified events fire.
---
--- @generic F: fun(bufnr: integer, ...): string
--- @param component F
--- @alias StCacheEvent string | {event: string, pattern: string}
--- @param spec {events: (StCacheEvent)[], buffer?: boolean, redraw?: boolean}
---        Autocmd specs that invalidate the cache.
---        When `buffer` is true, the cache is created separately per buffer.
---        When `buffer` is false (default), the cache is global for all buffers.
---        When `redraw` is true (default), redrawstatus will be called right after clearing the cache.
---        Events can be plain strings or tables with `event` and `pattern` keys, e.g. {event="OptionSet", pattern="modified"}.
--- @return F
function M.create(component, spec)
    spec.redraw = spec.redraw or true
    ---@type table<integer, string>
    local cache = {}

    local group = vim.api.nvim_create_augroup("StCached_" .. tostring(component), { clear = true })

    local invalidate_callback = function(ev)
        -- schedule avoids race condition by running only after other events stopped processing
        vim.schedule(function()
            if spec.buffer == true then
                ev.buf = ev.buf == 0 and vim.api.nvim_get_current_buf() or ev.buf
                cache[ev.buf] = nil
            else
                cache[global_cache_key] = nil
            end
            if spec.redraw then vim.cmd.redrawstatus() end
        end)
    end

    local plain_events = {}
    local desc = "invalidate cached statusline component '" .. tostring(component) .. "'"

    for _, event in ipairs(spec.events) do
        if type(event) == "table" then
            vim.api.nvim_create_autocmd(event.event, {
                group = group,
                pattern = event.pattern,
                callback = invalidate_callback,
                desc = desc,
            })
        else
            table.insert(plain_events, event)
        end
    end

    if #plain_events > 0 then
        vim.api.nvim_create_autocmd(plain_events, {
            group = group,
            callback = invalidate_callback,
            desc = desc,
        })
    end

    if spec.buffer == true then
        vim.api.nvim_create_autocmd("BufDelete", {
            group = group,
            callback = function(ev) cache[ev.buf] = nil end,
            desc = "clear cache for deleted buffer for '" .. tostring(component) .. "'",
        })
    end
    return function(bufnr, ...)
        local cache_key = bufnr
        if not spec.buffer then cache_key = global_cache_key end

        local result = cache[cache_key]
        if result ~= nil then return result end

        result = component(bufnr, ...)
        cache[cache_key] = result
        return result
    end
end

return M
