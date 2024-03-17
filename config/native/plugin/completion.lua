vim.opt.completeopt = { "menu", "menuone", "noselect" }

require("konrad.lazy").make_lazy_load("cmp", "InsertEnter", require("konrad.cmp").setup)
