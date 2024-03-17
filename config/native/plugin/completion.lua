vim.opt.completeopt = { "menu", "menuone", "noselect" }

local lazy = require("konrad.lazy")
lazy.make_lazy_load("cmp", "InsertEnter", function()
    local plugs = { "luasnip", "nvim-cmp", "cmp_luasnip", "cmp-buffer", "cmp-path", "cmp-nvim-lsp" }
    for _, plug in ipairs(plugs) do
        vim.cmd.packadd(plug)
    end
    lazy.load_after_plugin("cmp*.lua")

    require("konrad.cmp").setup()
end)
