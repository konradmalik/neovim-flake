local paths = require("pde.paths")
local parsers_dir = paths.get_and_ensure("site")
local treesitter = require("nvim-treesitter")

require("pde.loader").add_to_on_reset(function() vim.fn.delete(parsers_dir, "rf") end)

treesitter.setup({
    install_dir = parsers_dir,
})

local group = vim.api.nvim_create_augroup("pde-treesitter", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "*",
    callback = function(args)
        local ft = args.match
        local lang = vim.treesitter.language.get_lang(ft)
        if not lang then return end

        treesitter.install({ lang }):await(function(err)
            if err then return end

            local ok, _ = vim.treesitter.language.add(lang)
            if not ok then return end

            local bufnr = args.buf
            vim.treesitter.start(bufnr, lang)

            vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

            for _, win in ipairs(vim.api.nvim_list_wins()) do
                local winbuf = vim.api.nvim_win_get_buf(win)
                if winbuf == bufnr then
                    vim.wo[win].foldmethod = "expr"
                    vim.wo[win].foldexpr = "v:lua.vim.treesitter.foldexpr()"
                    vim.wo[win].foldtext = "v:lua.vim.treesitter.foldtext()"
                end
            end
        end)
    end,
})
