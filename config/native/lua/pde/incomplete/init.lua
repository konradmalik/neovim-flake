local M = {}

---@class CompleteItem
---@field word string actual completion value
---@field abbr string menu entry
---@field menu string menu entry label
---@field info? string additional info displayed next to menu entry

---@class CompleteDict
---@field words string|CompleteItem
---@field refresh? "always"|nil

function M.setup() vim.o.completefunc = "v:lua.require'pde.incomplete'.completefunc" end

---Exemplary stuff for fun and learning
---@param findstart integer
---@param base string
---@return integer|CompleteItem
function M.completefunc(findstart, base)
    if findstart == 1 and base == "" then
        -- column where completion starts
        -- eg. return 0 for start of the line
        -- return -1 for cursor column
        return -1
    end

    return {
        ---@type CompleteItem[]
        words = {
            {
                word = "¯\\_(ツ)_/¯",
                abbr = "shrug",
                menu = "ascii emoji",
                info = "when you have nothing better to say",
            },
            {
                word = "(╯°□°)╯彡┻━┻",
                abbr = "rageflip",
                menu = "ascii emoji",
                info = "when you have enough",
            },
        },
    }
end

return M
