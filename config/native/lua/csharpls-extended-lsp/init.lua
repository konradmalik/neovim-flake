local utils = require("csharpls-extended-lsp.utils")

local client_name = "csharp_ls"
local get_csharpls_client = function()
    local clients = vim.lsp.get_clients({ bufnr = 0, name = client_name })
    return clients[1]
end

local matcher = "metadata[/\\]projects[/\\](.*)[/\\]assemblies[/\\](.*)[/\\]symbols[/\\](.*).cs"
local is_meta_uri = function(uri)
    local found = string.find(uri, matcher)
    if found then
        return found
    end
    return nil
end

local textdocument_definition_to_locations = function(result)
    if not vim.tbl_islist(result) then
        return { result }
    end

    return result
end

local buf_from_metadata = function(result, working_dir)
    local normalized = string.gsub(result.source, "\r\n", "\n")
    local source_lines = utils.split(normalized, "\n")

    local file_name =
        table.concat({ working_dir, result.projectName, "$metadata$", result.assemblyName, result.symbolName }, "/")

    -- this will be /$metadata$/...
    local bufnr = utils.get_or_create_buf(file_name)
    -- TODO: check if bufnr == 0 -> error
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, source_lines)
    vim.api.nvim_set_option_value("readonly", true, { buf = bufnr })
    vim.api.nvim_set_option_value("modified", false, { buf = bufnr })
    vim.api.nvim_set_option_value("filetype", "cs", { buf = bufnr })

    return bufnr, file_name
end

---Gets metadata for all locations with $metadata$
---Creates buffers with their contents.
---For now we don't use the result of this function, but maybe we'll do
---@return table results table
local get_metadata = function(locations)
    local client = get_csharpls_client()
    if not client then
        vim.notify(string.format("cannot find %s client", client_name), vim.log.levels.ERROR)
        return {}
    end

    local fetched = {}
    for _, loc in pairs(locations) do
        local uri = utils.urldecode(loc.uri)
        local is_meta = is_meta_uri(uri)
        if is_meta then
            local params = {
                timeout = 5000,
                textDocument = {
                    uri = uri,
                },
            }
            local result, err = client.request_sync("csharp/metadata", params, 10000)
            if not err then
                local bufnr, name = buf_from_metadata(result.result, client.config.root_dir)
                vim.lsp.buf_attach_client(bufnr, client.id)
                -- change location name to the one returned from metadata
                -- alternative is to open buffer under location uri
                -- not sure which one is better
                loc.uri = "file://" .. name
                fetched[loc.uri] = {
                    bufnr = bufnr,
                    range = loc.range,
                }
            end
        end
    end

    return fetched
end

local handle_locations = function(locations, offset_encoding)
    local fetched = get_metadata(locations)
    if vim.tbl_isempty(fetched) then
        return false
    end

    if #locations > 1 then
        utils.set_qflist_locations(locations, offset_encoding)
        vim.api.nvim_command("copen")
    else
        vim.lsp.util.jump_to_location(locations[1], offset_encoding)
    end
    return true
end

local M = {}

M.handler = function(err, result, ctx, config)
    local offset_encoding = vim.lsp.get_client_by_id(ctx.client_id).offset_encoding
    local locations = textdocument_definition_to_locations(result)
    local handled = handle_locations(locations, offset_encoding)
    if not handled then
        return vim.lsp.handlers["textDocument/definition"](err, result, ctx, config)
    end
end

return M
