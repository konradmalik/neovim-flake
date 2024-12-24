-- https://github.com/valentjn/ltex-ls

local binaries = require("pde.binaries")
local paths = require("pde.paths")

local dictionary = {}
local disabledRules = {}
local hiddenFalsePositives = {}

local name = "ltex"
local current_language = "en-US"

---@param path string
---@param lines string[]
local function append_to_file(path, lines)
    local file = io.open(path, "a")
    if file then
        for _, line in ipairs(lines) do
            file:write(line .. "\n")
        end
        file:close()
    end
end

---@param command lsp.Command
---@return boolean
local function validate_command(command)
    if #command.arguments ~= 1 then
        vim.notify("unexpected arguments: " .. vim.inspect(command.arguments), vim.log.levels.ERROR)
        return false
    end

    return true
end

---@param path string file to read
---@param target string[] target to append the lines to
local function read_lines_into(path, target)
    local file = io.open(path, "r")
    if file then
        for line in file:lines() do
            table.insert(target, line)
        end

        file:close()
    end
end

---@param command table
---@param key string
---@param tbl table<string,string[]>
---@return table<string,string[]>
local function handle_action(command, key, tbl)
    if not validate_command(command) then return {} end

    local entries = command.arguments[1][key]
    for lang, entry in pairs(entries) do
        if not tbl[lang] then tbl[lang] = {} end
        vim.list_extend(tbl[lang], entry)
    end
    return entries
end

local update_client_with = function(changed_settings)
    local client = vim.lsp.get_clients({ name = name })[1]
    if not client then return end
    client:notify("workspace/didChangeConfiguration", { settings = changed_settings })
end

local function get_dictionary_file(language) return paths.get_spellfile(vim.split(language, "-")[1]) end

local function get_false_positives_file(language)
    return paths.get_spellfile(nil) .. "/ltex_false-positives_" .. language .. ".txt"
end

local function get_disabled_rules_file(language)
    return paths.get_spellfile(nil) .. "/ltex_disabled-rules_" .. language .. ".txt"
end

vim.lsp.config(name, {
    cmd = { binaries.ltex_ls() },
    filetypes = { "markdown" },
    before_init = function()
        if not dictionary[current_language] then
            dictionary[current_language] = {}
            read_lines_into(get_dictionary_file(current_language), dictionary[current_language])
        end

        if not hiddenFalsePositives[current_language] then
            hiddenFalsePositives[current_language] = {}
            read_lines_into(
                get_false_positives_file(current_language),
                hiddenFalsePositives[current_language]
            )
        end

        if not disabledRules[current_language] then
            disabledRules[current_language] = {}
            read_lines_into(
                get_disabled_rules_file(current_language),
                disabledRules[current_language]
            )
        end
    end,
    settings = {
        ltex = {
            enabled = { "html", "markdown" },
            language = current_language,
            checkFrequency = "save",
            dictionary = dictionary,
            disabledRules = disabledRules,
            hiddenFalsePositives = hiddenFalsePositives,
        },
    },
    on_attach = function(_, buf)
        vim.api.nvim_buf_call(buf, function() vim.o.spell = false end)
        -- TODO: buf_command for changing the language
    end,
    commands = {
        ["_ltex.addToDictionary"] = function(command)
            local new = handle_action(command, "words", dictionary)
            update_client_with({ ltex = { dictionary = dictionary } })
            for lang, entries in pairs(new) do
                local path = get_dictionary_file(lang)
                append_to_file(path, entries)
            end
            vim.cmd("MkSpell")
        end,
        ["_ltex.hideFalsePositives"] = function(command)
            local new = handle_action(command, "falsePositives", hiddenFalsePositives)
            update_client_with({ ltex = { hiddenFalsePositives = hiddenFalsePositives } })
            for lang, entries in pairs(new) do
                local path = get_false_positives_file(lang)
                append_to_file(path, entries)
            end
        end,
        ["_ltex.disableRules"] = function(command)
            local new = handle_action(command, "ruleIds", disabledRules)
            update_client_with({ ltex = { disabledRules = disabledRules } })
            for lang, entries in pairs(new) do
                local path = get_disabled_rules_file(lang)
                append_to_file(path, entries)
            end
        end,
    },
})
