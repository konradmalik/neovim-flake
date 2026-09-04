-- https://writewithharper.com/docs/integrations/neovim
local function get_user_dictionary_file(language)
    return require("pde.paths").get_spellfile(vim.split(language, "-")[1])
end

local function get_file_dictionary_dir() return require("pde.paths").get_spellfile(nil) end

---@type vim.lsp.Config
return {
    on_attach = function(_, bufnr)
        -- 'spell' is window-local, but `vim.wo[win][0]` sets the value nvim
        -- remembers per buffer, so clearing it in one window is enough: the
        -- buffer carries it into every window it is shown in afterwards.
        ---@return boolean whether the buffer was displayed anywhere
        local function disable_spell()
            local wins = vim.fn.win_findbuf(bufnr)
            for _, win in ipairs(wins) do
                vim.wo[win][0].spell = false
            end
            return #wins > 0
        end

        -- the client can attach before the buffer is in a window, in which
        -- case there is nothing to set yet; returning true from the callback
        -- deletes the autocmd, so it only ever runs until it succeeds once
        if not disable_spell() then
            vim.api.nvim_create_autocmd("BufWinEnter", {
                group = vim.api.nvim_create_augroup("pde-harper-spell", { clear = false }),
                buffer = bufnr,
                callback = disable_spell,
                desc = "harper_ls provides the spelling, so turn off nvim's",
            })
        end
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
