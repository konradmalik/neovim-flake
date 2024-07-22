require("lz.n").load({
    "luasnip",
    event = "InsertEnter",
    after = function()
        require("pde.snippets.generic")

        local ls = require("luasnip")

        vim.snippet.expand = ls.lsp_expand

        ---@diagnostic disable-next-line: duplicate-set-field
        vim.snippet.active = function(filter)
            filter = filter or {}
            filter.direction = filter.direction or 1

            if filter.direction == 1 then
                return ls.expand_or_jumpable()
            else
                return ls.jumpable(filter.direction)
            end
        end

        ---@diagnostic disable-next-line: duplicate-set-field
        vim.snippet.jump = function(direction)
            if direction == 1 then
                if ls.expandable() then
                    return ls.expand_or_jump()
                else
                    return ls.jumpable(1) and ls.jump(1)
                end
            else
                return ls.jumpable(-1) and ls.jump(-1)
            end
        end

        vim.snippet.stop = ls.unlink_current
    end,
})

vim.keymap.set(
    { "i", "s" },
    "<c-k>",
    function() return vim.snippet.active({ direction = 1 }) and vim.snippet.jump(1) end,
    { silent = true }
)

vim.keymap.set(
    { "i", "s" },
    "<c-j>",
    function() return vim.snippet.active({ direction = -1 }) and vim.snippet.jump(-1) end,
    { silent = true }
)
