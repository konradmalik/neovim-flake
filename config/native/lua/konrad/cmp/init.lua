local cmp = require("cmp")

local M = {}

M.default_sources = {
    { name = "luasnip" },
    { name = "buffer" },
    { name = "path" },
}

M.setup = function()
    -- register custom and vscode snippets to luasnip
    require("konrad.cmp.snippets")

    local kind_icons = require("konrad.icons").kind
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
        kinds[i] = kind_icons[kind] or kind
    end

    cmp.setup({
        -- completion = {
        --     autocomplete = false,
        -- },
        snippet = {
            expand = function(args) vim.snippet.expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
            ["<C-d>"] = cmp.mapping.scroll_docs(-4),
            ["<C-f>"] = cmp.mapping.scroll_docs(4),
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<C-e>"] = cmp.mapping.abort(),
            ["<C-y>"] = cmp.mapping.confirm({
                behavior = cmp.ConfirmBehavior.Insert,
                select = true,
            }),
            ["<M-y>"] = cmp.mapping.confirm({
                behavior = cmp.ConfirmBehavior.Replace,
                select = false,
            }),
            ["<C-n>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_next_item()
                elseif vim.snippet.jumpable(1) then
                    vim.snippet.jump(1)
                else
                    fallback()
                end
            end, { "i", "s" }),
            ["<C-p>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item()
                elseif vim.snippet.jumpable(-1) then
                    vim.snippet.jump(-1)
                else
                    fallback()
                end
            end, { "i", "s" }),
            ["<tab>"] = cmp.config.disable,
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
        sources = cmp.config.sources(M.default_sources),
        window = {
            completion = cmp.config.window.bordered(),
            documentation = cmp.config.window.bordered(),
        },
    })
end

return M
