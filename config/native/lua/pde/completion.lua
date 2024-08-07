local M = {}

M.setup = function()
    local icons = {
        Class = "",
        Color = "",
        Constant = "",
        Constructor = "",
        Copilot = "",
        Enum = "",
        EnumMember = "",
        Event = "",
        Field = "",
        File = "",
        Folder = "",
        Function = "󰊕",
        Interface = "",
        Keyword = "",
        Method = "m",
        Module = "",
        Operator = "",
        Property = "",
        Reference = "",
        Snippet = "",
        Struct = "",
        Text = "",
        TypeParameter = "",
        Unit = "",
        Value = "",
        Variable = "",
    }

    vim.opt.shortmess:append("c")
    vim.opt.completeopt = { "menu", "menuone", "noselect" }

    local menu_entries = {
        -- lsp gets lsp server name via client.name
        luasnip = "[Snippet]",
        buffer = "[Buffer]",
        path = "[Path]",
    }

    -- fill native LSP completion_item_kind
    -- cmp is filled below in format
    local kinds = vim.lsp.protocol.CompletionItemKind
    for i, kind in ipairs(kinds) do
        kinds[i] = icons[kind] or kind
    end

    local cmp = require("cmp")
    cmp.setup({
        snippet = {
            expand = function(args) vim.snippet.expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
            ["<C-b>"] = cmp.mapping.scroll_docs(-4),
            ["<C-f>"] = cmp.mapping.scroll_docs(4),
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<C-e>"] = cmp.mapping.abort(),
            ["<C-y>"] = cmp.mapping.confirm({ select = true }),
            ["<C-n>"] = cmp.mapping.select_next_item(),
            ["<C-p>"] = cmp.mapping.select_prev_item(),
        }),
        formatting = {
            fields = { "kind", "abbr", "menu" },
            format = function(entry, vim_item)
                vim_item.kind = icons[vim_item.kind] or vim_item.kind
                if entry.source.name == "nvim_lsp" then
                    -- name of lsp client
                    vim_item.menu = "[" .. entry.source.source.client.name .. "]"
                else
                    vim_item.menu = menu_entries[entry.source.name] or entry.source.name
                end
                return vim_item
            end,
        },
        sources = {
            { name = "nvim_lsp" },
            { name = "luasnip" },
            { name = "buffer" },
            { name = "path" },
        },
    })
end

return M
