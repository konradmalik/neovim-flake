-- https://github.com/folke/snacks.nvim/blob/main/lua/snacks/bigfile.lua

local bigfile_ft = "bigfile"
local max_size = 1.5 * 1024 * 1024 -- bytes
local max_avg_line_length = 1000 -- catches minified files

vim.filetype.add({
    pattern = {
        [".*"] = {
            function(path, buf)
                -- the FileType callback below re-runs detection to get the real filetype
                if not path or not buf or vim.bo[buf].filetype == bigfile_ft then return end
                -- match() may be called with a filename that isn't the buffer's own
                if path ~= vim.api.nvim_buf_get_name(buf) then return end

                local size = vim.fn.getfsize(path)
                if size <= 0 then return end
                local lines = vim.api.nvim_buf_line_count(buf)
                if size > max_size or (size - lines) / lines > max_avg_line_length then return bigfile_ft end
            end,
            -- must win over other patterns (e.g. the nix-shebang detector in filetype.lua)
            { priority = 10 },
        },
    },
})

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("pde-bigfile", { clear = true }),
    pattern = bigfile_ft,
    callback = function(ev)
        local buf = ev.buf
        vim.notify(
            ("Big file detected `%s`. Some Neovim features have been disabled."):format(
                vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":p:~:.")
            ),
            vim.log.levels.WARN
        )

        -- empty matchpairs makes matchparen bail out for this buffer only (:NoMatchParen is global)
        vim.bo[buf].matchpairs = ""
        vim.bo[buf].autocomplete = false
        vim.wo[0][0].foldmethod = "manual"
        vim.wo[0][0].statuscolumn = ""
        vim.wo[0][0].conceallevel = 0
        -- regex syntax is cheap compared to treesitter/LSP; scheduled so the
        -- Syntax event for "bigfile" doesn't reset it
        vim.schedule(function()
            if vim.api.nvim_buf_is_valid(buf) then vim.bo[buf].syntax = vim.filetype.match({ buf = buf }) or "" end
        end)
    end,
})
