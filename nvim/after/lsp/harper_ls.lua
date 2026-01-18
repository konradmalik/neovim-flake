-- https://writewithharper.com/docs/integrations/neovim
local paths = require("pde.paths")

local function get_user_dictionary_file(language)
    return paths.get_spellfile(vim.split(language, "-")[1])
end

local function get_file_dictionary_dir() return paths.get_spellfile(nil) end

---@type vim.lsp.Config
return {
    on_attach = function(_, bufnr)
        vim.api.nvim_buf_call(bufnr, function() vim.o.spell = false end)
    end,
    settings = {
        ["harper-ls"] = {
            linters = {
                SentenceCapitalization = false,
            },
            userDictPath = get_user_dictionary_file("us"),
            fileDictPath = get_file_dictionary_dir(),
            isolateEnglish = true,
        },
    },
}
