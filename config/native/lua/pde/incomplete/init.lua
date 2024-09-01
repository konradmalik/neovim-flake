local cached_snippets = {
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
}

local M = {}

---@class CompleteItem
---@field word string actual completion value
---@field menu string menu entry label
---@field abbr? string menu entry
---@field info? string additional info displayed next to menu entry
---@field user_data {source: {incomplete: true}}

---@class CompleteDict
---@field words string|CompleteItem
---@field refresh? "always"|nil

function M.setup()
    local gr = vim.api.nvim_create_augroup("incomplete", { clear = true })
    vim.api.nvim_create_autocmd("CompleteDone", {
        group = gr,
        callback = function()
            local completed_item = vim.v.completed_item
            if not vim.tbl_get(completed_item, "user_data", "source", "incomplete") then return end

            if vim.tbl_get(vim.v.event, "reason") == "accept" then
                local word = completed_item.word ---@type string
                local snippet = cached_snippets[word]
                -- no cached snippet like that
                if not snippet then return end

                local cursor = vim.api.nvim_win_get_cursor(vim.api.nvim_get_current_win())
                local row, col = cursor[1] - 1, cursor[2]
                vim.api.nvim_buf_set_text(
                    vim.api.nvim_get_current_buf(),
                    row,
                    col - #word,
                    row,
                    col,
                    {}
                )
                vim.snippet.expand(snippet.body)
            end
        end,
    })

    vim.o.completefunc = "v:lua.require'pde.incomplete'.completefunc"
end

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
                word = "shrug",
                menu = "snippet",
                info = "when you have nothing better to say",
                user_data = { source = { incomplete = true } },
            },
            {
                word = "rageflip",
                menu = "snippet",
                info = "when you have enough",
                user_data = { source = { incomplete = true } },
            },
        },
    }
end

return M
