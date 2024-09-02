local loaded_snippets = {
    all = {
        shrug = {
            body = "¯\\_(ツ)_/¯",
            prefix = "shrug",
            description = "when you have nothing better to say",
        },
        rageflip = {
            body = "(╯°□°)╯彡┻━┻",
            prefix = "rageflip",
            description = "when you have enough",
        },
    },
}

local M = {}

--TODO actually load from somewhere
---@param ft string filetype or "all" for non-filetype specific
---@return table[]
function M.load_for(ft) return loaded_snippets[ft] end

---converts json snippets into incomplete
---@param snips table<string, table>[]
---@return CompleteItem[]
function M.convert(snips)
    return vim.tbl_values(vim.tbl_map(function(value)
        ---@type CompleteItem
        return {
            word = value.prefix,
            menu = "snippet",
            info = value.description,
            user_data = { incomplete = value },
        }
    end, snips))
end

return M
