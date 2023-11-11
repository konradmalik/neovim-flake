local U = {}

U.hex_to_char = function(x)
    return string.char(tonumber(x, 16))
end

U.urldecode = function(url)
    if url == nil then
        return
    end
    url = url:gsub("+", " ")
    url = url:gsub("%%(%x%x)", U.hex_to_char)
    return url
end

U.split = function(str, delimiter)
    -- https://gist.github.com/jaredallard/ddb152179831dd23b230
    local result = {}
    local from = 1
    local delim_from, delim_to = string.find(str, delimiter, from)
    while delim_from do
        table.insert(result, string.sub(str, from, delim_from - 1))
        from = delim_to + 1
        delim_from, delim_to = string.find(str, delimiter, from)
    end
    table.insert(result, string.sub(str, from))
    return result
end

U.get_or_create_buf = function(name)
    -- if we are looking for $metadata$ buffer, search for entire string anywhere
    -- in buffer name. On Windows nvim_buf_set_name might change the buffer name and include some stuff before.
    local looking_for_metadata = string.find(name, "^/%$metadata%$/.*$")

    local buffers = vim.api.nvim_list_bufs()
    for _, buf in pairs(buffers) do
        local bufname = vim.api.nvim_buf_get_name(buf)

        if looking_for_metadata then
            local normalized_bufname = string.gsub(bufname, "\\", "/")
            if string.find(normalized_bufname, name) then
                return buf
            end
        else
            if bufname == name then
                return buf
            -- Match a bufname like C:\System.Console
            elseif string.find(string.gsub(bufname, "%u:\\", "/"), name) then
                return buf
            end
        end
    end

    local bufnr = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_buf_set_name(bufnr, name)
    return bufnr
end

U.set_qflist_locations = function(locations, offset_encoding)
    local items = vim.lsp.util.locations_to_items(locations, offset_encoding)
    vim.fn.setqflist({}, " ", {
        title = "Language Server",
        items = items,
    })
end

return U
