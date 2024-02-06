require("kanagawa").setup({
    compile = true,
    background = {
        dark = "wave",
        light = "lotus",
    },
    -- https://github.com/rebelot/kanagawa.nvim/issues/197#issue-2092178700
    overrides = function()
        return {
            -- update kanagawa to handle new treesitter highlight captures
            ["@comment.danger"] = { link = "@text.danger" },
            ["@comment.note"] = { link = "@text.note" },
            ["@comment.todo"] = { link = "@text.todo" },
            ["@comment.warning"] = { link = "@text.warning" },
            ["@diff.minus"] = { link = "@text.diff.delete" },
            ["@diff.plus"] = { link = "@text.diff.add" },
            ["@exception"] = { link = "@exception" },
            ["@markup.environment"] = { link = "@text.environment" },
            ["@markup.environment.name"] = { link = "@text.environment.name" },
            ["@markup.heading"] = { link = "@text.title" },
            ["@markup.italic"] = { link = "@text.emphasis" },
            ["@markup.link.label"] = { link = "Identifier" },
            ["@markup.link.url"] = { link = "Special" },
            ["@markup.math"] = { link = "@text.math" },
            ["@markup.quote"] = { link = "@text.quote" },
            ["@markup.raw"] = { link = "@text.literal" },
            ["@markup.strong"] = { link = "@text.strong" },
            ["@string.regexp"] = { link = "@string.regex" },
            ["@string.special.symbol"] = { link = "@symbol" },
            ["@variable.parameter"] = { link = "@parameter" },
        }
    end,
})

vim.opt.background = "dark"
vim.cmd("colorscheme kanagawa")
