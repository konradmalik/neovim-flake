---@param ft string filetype or "all" for non-filetype specific
---@return table[]
local function read(ft)
    local jsons = vim.api.nvim_get_runtime_file("snippets/" .. ft .. ".json", true)
    vim.list_extend(jsons, vim.api.nvim_get_runtime_file("snippets/" .. ft .. "/**/*.json", true))
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
local function convert(snips)
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

local M = {}

---Reads snippets from json files (files must be in snippets/<ft>.json)
---and from folders (snippets/<ft>/**/<anyname>.json)
---@param ft string filetype or "all" for non-filetype specific
---@return table[]
function M.load_for(ft)
    local snips = read(ft)
    return convert(snips)
end

return M
