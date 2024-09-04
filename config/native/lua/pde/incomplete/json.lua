local M = {}

---@param ft string filetype or "all" for non-filetype specific
---@return table[]
function M.load_for(ft)
    local jsons = vim.api.nvim_get_runtime_file("snippets/**/" .. ft .. ".json", true)
    return vim.iter(jsons)
        :map(function(file)
            local lines = vim.fn.readfile(file)
            local str = table.concat(lines, "")
            return vim.json.decode(str)
        end)
        :fold({}, function(acc, v) return vim.tbl_deep_extend("force", acc, v) end)
end

---converts json snippets into incomplete
---@param snips table<string, table>[]
---@return CompleteItem[]
function M.convert(snips)
    return vim.tbl_values(vim.tbl_map(function(value)
        ---@type CompleteItem
        return {
            word = value.prefix,
            menu = "󰩫",
            info = value.description,
            user_data = { incomplete = value },
        }
    end, snips))
end

return M
