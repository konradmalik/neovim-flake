-- lazy load snippets
require("konrad.cmp.snippets")

local utils = require("konrad.utils")
-- load copilot on demand
utils.make_enable_command(
    "CopilotEnable",
    { "copilot.lua", "copilot-cmp" },
    function()
        require("konrad.cmp.copilot")
    end,
    {
        desc = "Initialize Copilot server and cmp source",
    })

local cmp = require("cmp")

local kind_icons = require("konrad.icons").kind
local menu_entries = {
    -- copilot runs on demand via 'CopilotEnable' command
    copilot = "[Copilot]",
    nvim_lsp = "[LSP]",
    luasnip = "[Snippet]",
    buffer = "[Buffer]",
    path = "[Path]",
}

cmp.setup({
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<C-y>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        }),
        ['<C-n>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif require('luasnip').expand_or_jumpable() then
                require('luasnip').expand_or_jump()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<C-p>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif require('luasnip').jumpable(-1) then
                require('luasnip').jump(-1)
            else
                fallback()
            end
        end, { 'i', 's' }),
    }),
    formatting = {
        fields = { "kind", "abbr", "menu" },
        format = function(entry, vim_item)
            vim_item.kind = kind_icons[vim_item.kind]
            if entry.source.name == "nvim_lsp" then
                -- name of lsp client
                vim_item.menu = '[' .. entry.source.source.client.name .. ']'
            else
                vim_item.menu = menu_entries[entry.source.name] or entry.source.name
            end
            return vim_item
        end,
    },
    sources = cmp.config.sources({
        { name = "copilot" },
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "buffer" },
        { name = "path" },
    }),
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
})
