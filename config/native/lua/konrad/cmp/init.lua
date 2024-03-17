local M = {}

M.setup = function()
    -- register custom and vscode snippets to luasnip
    require("konrad.cmp.snippets")

    local menu_entries = {
        -- lsp gets lsp server name via client.name
        luasnip = "[Snippet]",
        buffer = "[Buffer]",
        path = "[Path]",
    }

    -- fill native LSP completion_item_kind
    -- cmp is filled below in format
    local kinds = vim.lsp.protocol.CompletionItemKind
    local kind_icons = require("konrad.icons").kind
    for i, kind in ipairs(kinds) do
        kinds[i] = kind_icons[kind] or kind
    end

    local cmp = require("cmp")
    cmp.setup({
        snippet = {
            expand = function(args) vim.snippet.expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
            ["<C-d>"] = cmp.mapping.scroll_docs(-4),
            ["<C-f>"] = cmp.mapping.scroll_docs(4),
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<C-e>"] = cmp.mapping.abort(),
            ["<C-y>"] = cmp.mapping.confirm({ select = true }),
            ["<C-n>"] = cmp.mapping.select_next_item(),
            ["<C-p>"] = cmp.mapping.select_prev_item(),
            ["<C-l>"] = cmp.mapping(function()
                if vim.snippet.jumpable(1) then vim.snippet.jump(1) end
            end, { "i", "s" }),
            ["<C-h>"] = cmp.mapping(function()
                if vim.snippet.jumpable(-1) then vim.snippet.jump(-1) end
            end, { "i", "s" }),
        }),
        formatting = {
            fields = { "kind", "abbr", "menu" },
            format = function(entry, vim_item)
                vim_item.kind = kind_icons[vim_item.kind] or vim_item.kind
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
            { name = "luasnip" },
            { name = "buffer" },
            { name = "path" },
            { name = "nvim_lsp" },
        },
        window = {
            completion = cmp.config.window.bordered(),
            documentation = cmp.config.window.bordered(),
        },
    })
end

return M
