local M = {}

-- to remove trailing slash if present in watcher uris
-- prevents: code = "SERVER_REQUEST_HANDLER_ERROR",  err = "...-unwrapped-89a9745/share/nvim/runtime/lua/vim/_watch.lua:74: ENOENT: no such file or directory
function M.with_filtered_watchers(handler)
    return function(err, res, ctx, config)
        for _, reg in ipairs(res.registrations) do
            if reg.method == vim.lsp.protocol.Methods.workspace_didChangeWatchedFiles then
                reg.registerOptions.watchers = vim.tbl_filter(function(watcher)
                    if type(watcher.globPattern) == "table" then
                        local base_uri = nil ---@type string?
                        if type(watcher.globPattern.baseUri) == "string" then
                            base_uri = watcher.globPattern.baseUri
                            if base_uri:sub(-1) == "/" then
                                watcher.globPattern.baseUri = base_uri:sub(1, -2)
                            end
                        elseif type(watcher.globPattern.baseUri) == "table" then
                            base_uri = watcher.globPattern.baseUri.uri
                            if base_uri:sub(-1) == "/" then
                                watcher.globPattern.baseUri.uri = base_uri:sub(1, -2)
                            end
                        end

                        if base_uri ~= nil then
                            local base_dir = vim.uri_to_fname(base_uri)
                            -- use luv to check if baseDir is a directory
                            local stat = vim.loop.fs_stat(base_dir)
                            return stat ~= nil and stat.type == "directory"
                        end
                    end

                    return true
                end, reg.registerOptions.watchers)
            end
        end
        return handler(err, res, ctx, config)
    end
end

return M
