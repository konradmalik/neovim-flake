-- https://writewithharper.com/docs/integrations/neovim
-- grammar only, and only for prose: nvim's own 'spell' does the spelling,
-- but harper reads its good words so they don't trip the grammar linters
local function get_user_dictionary_file() return vim.split(vim.o.spellfile, ",")[1] end

---@type uv.uv_fs_event_t?
local dictionary_watcher

-- harper only reads the dictionary when its config changes, so resend the
-- config to every client whenever `zg` and friends write to the spellfile.
-- Watching the directory also catches rewrites that replace the file.
---@param name string the clients to notify
local function watch_user_dictionary(name)
    if dictionary_watcher then return end
    local file = get_user_dictionary_file()
    dictionary_watcher = assert(vim.uv.new_fs_event())
    dictionary_watcher:start(
        vim.fs.dirname(file),
        {},
        vim.schedule_wrap(function(err, filename)
            if err or filename ~= vim.fs.basename(file) then return end
            for _, client in ipairs(vim.lsp.get_clients({ name = name })) do
                client:notify("workspace/didChangeConfiguration", { settings = client.settings })
            end
        end)
    )
end

---@type vim.lsp.Config
return {
    filetypes = { "markdown", "text" },
    on_init = function(client) watch_user_dictionary(client.name) end,
    settings = {
        ["harper-ls"] = {
            linters = {
                SpellCheck = false,
                SentenceCapitalization = false,
                LongSentences = false,
            },
            diagnosticSeverity = "hint",
            userDictPath = get_user_dictionary_file(),
            isolateEnglish = true,
        },
    },
}
