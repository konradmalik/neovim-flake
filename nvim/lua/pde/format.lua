---Formats buffers with external commands, conform-style but without conform.
---
---The buffer is piped to the formatter on stdin together with the real file path, so that
---the formatter itself resolves .editorconfig, .prettierrc, stylua.toml and friends.
---The output is diffed against the buffer and only the changed bytes are replaced,
---which keeps extmarks and marks on untouched text.
local M = {}

---@class pde.format.Opts
---formatter name -> command, an argument that is exactly "$FILENAME" becomes the buffer's file path
---@field formatters? table<string, string[]|false>
---filetype -> formatter names, run in order with each one's output fed to the next
---@field formatters_by_ft? table<string, string[]|false>

---Each layer is a shallow merge of all calls made to it: a key given again replaces the
---old value whole, other keys stay. Overrides are looked up first, so .nvim.lua
---wins over the defaults no matter which ran first; false there disables a default.
---@type pde.format.Opts
local defaults = { formatters = {}, formatters_by_ft = {} }
---@type pde.format.Opts
local overrides = { formatters = {}, formatters_by_ft = {} }

---@param layer pde.format.Opts
---@param opts pde.format.Opts
local function merge(layer, opts)
    layer.formatters = vim.tbl_extend("force", layer.formatters, opts.formatters or {})
    layer.formatters_by_ft = vim.tbl_extend("force", layer.formatters_by_ft, opts.formatters_by_ft or {})
end

---@param field "formatters"|"formatters_by_ft"
---@param key string
---@return string[]?
local function lookup(field, key)
    local value = overrides[field][key]
    if value == nil then value = defaults[field][key] end
    return value or nil
end

---@param a string
---@param b string
---@return integer
local function common_prefix_len(a, b)
    local len = math.min(#a, #b)
    for i = 1, len do
        if a:byte(i) ~= b:byte(i) then return i - 1 end
    end
    return len
end

---@param a string
---@param b string
---@return integer
local function common_suffix_len(a, b)
    local len = math.min(#a, #b)
    for i = 0, len - 1 do
        if a:byte(#a - i) ~= b:byte(#b - i) then return i end
    end
    return len
end

---Turn one diff hunk into a text edit, narrowed to the changed bytes for replacements.
---Ported from conform.nvim's runner.
---@param old_lines string[]
---@param new_lines string[]
---@param hunk integer[] as returned by vim.text.diff with result_type = "indices"
---@return lsp.TextEdit
local function hunk_to_text_edit(old_lines, new_lines, hunk)
    local old_start, old_count, new_start, new_count = unpack(hunk)
    local replacement = vim.list_slice(new_lines, new_start, new_start + new_count - 1)
    -- 0-based, end exclusive
    local start_line, end_line = old_start - 1, old_start - 1 + old_count
    local start_char, end_char = 0, 0

    if old_count == 0 then
        -- an insert means "after old_start"
        start_line, end_line = old_start, old_start
        -- the text needs its own line break, except at the end of the buffer where it is implicit;
        -- there apply_text_edits also drops a trailing empty line, so blank lines a formatter
        -- appends at the very end are lost (as with conform, and autoformat trims them anyway)
        if start_line < #old_lines then table.insert(replacement, "") end
    elseif new_count > 0 then
        -- a replacement: end on the last replaced line itself and skip the unchanged prefix/suffix
        end_line = end_line - 1
        -- always a real line: apply_diff terminates the last line, so hunks never point past it
        local first, last = old_lines[old_start], old_lines[end_line + 1]
        start_char = common_prefix_len(first, replacement[1])
        replacement[1] = replacement[1]:sub(start_char + 1)

        local suffix = common_suffix_len(last, replacement[#replacement])
        -- on a single line the prefix and suffix must not overlap
        if start_line == end_line then suffix = math.min(suffix, #last - start_char) end
        end_char = #last - suffix
        replacement[#replacement] = replacement[#replacement]:sub(1, -suffix - 1)
    end

    return {
        newText = table.concat(replacement, "\n"),
        range = {
            start = { line = start_line, character = start_char },
            ["end"] = { line = end_line, character = end_char },
        },
    }
end

---@param bufnr integer
---@param old_lines string[]
---@param new_lines string[]
local function apply_diff(bufnr, old_lines, new_lines)
    -- terminate the last line too, not only the ones in between: the diff compares line
    -- breaks as well, so an unterminated last line would differ from the same text with
    -- a line after it, turning an append into a rewrite of that last line
    local hunks = vim.text.diff(
        table.concat(old_lines, "\n") .. "\n",
        table.concat(new_lines, "\n") .. "\n",
        { result_type = "indices", algorithm = "histogram" }
    )
    ---@cast hunks integer[][]
    if #hunks == 0 then return end

    local edits = vim.tbl_map(function(hunk) return hunk_to_text_edit(old_lines, new_lines, hunk) end, hunks)
    vim.lsp.util.apply_text_edits(edits, bufnr, "utf-8")
end

---Configure the defaults, meant for the main config.
---@param opts pde.format.Opts
function M.setup(opts) merge(defaults, opts) end

---Configure on top of the defaults, meant for .nvim.lua; always wins over setup().
---@param opts pde.format.Opts
function M.override(opts) merge(overrides, opts) end

---@param bufnr integer?
---@return boolean
function M.has_formatter(bufnr)
    local names = lookup("formatters_by_ft", vim.bo[bufnr or 0].filetype)
    return names ~= nil and #names > 0
end

---Run one formatter on the given text.
---@param name string
---@param filename string
---@param input string
---@param timeout_ms integer
---@return string? output nil when the formatter could not format the text, already reported
local function run(name, filename, input, timeout_ms)
    local cmd = lookup("formatters", name)
    if not cmd then
        vim.notify(("formatter '%s' is not configured"):format(name), vim.log.levels.ERROR)
        return
    end
    if vim.fn.executable(cmd[1]) == 0 then
        vim.notify(("formatter '%s' not found"):format(cmd[1]), vim.log.levels.WARN)
        return
    end

    cmd = vim.tbl_map(function(arg) return arg == "$FILENAME" and filename or arg end, cmd)
    -- text = true turns CRLF output into plain line breaks, 'fileformat' decides them on write
    local ok, proc = pcall(vim.system, cmd, { stdin = input, text = true, cwd = vim.fs.dirname(filename) })
    if not ok then
        vim.notify(("formatter '%s' failed to start: %s"):format(name, proc), vim.log.levels.ERROR)
        return
    end
    local result = proc:wait(timeout_ms)
    if result.code ~= 0 then
        -- 124 is what vim.system reports when it killed the process on timeout
        local reason = result.code == 124 and "timed out" or vim.trim(result.stderr or "")
        vim.notify(("formatter '%s' failed: %s"):format(name, reason), vim.log.levels.ERROR)
        return
    end

    local output = result.stdout or ""
    -- some formatters print nothing for files they ignore
    if output:match("^%s*$") and not input:match("^%s*$") then return end
    return output
end

---Format the buffer synchronously with its filetype's formatters, if it has any.
---The buffer is only changed when every formatter in the chain succeeded.
---@param bufnr integer?
---@param timeout_ms integer per formatter
function M.format(bufnr, timeout_ms)
    if not bufnr or bufnr == 0 then bufnr = vim.api.nvim_get_current_buf() end
    local names = lookup("formatters_by_ft", vim.bo[bufnr].filetype)
    if not names then return end

    local filename = vim.api.nvim_buf_get_name(bufnr)
    local old_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local input = table.concat(old_lines, "\n") .. "\n"
    local output = input
    for _, name in ipairs(names) do
        local next_output = run(name, filename, output, timeout_ms)
        if not next_output then return end
        output = next_output
    end
    if output == input then return end

    local new_lines = vim.split(output, "\n", { plain = true })
    if new_lines[#new_lines] == "" then table.remove(new_lines) end
    apply_diff(bufnr, old_lines, new_lines)
end

---Report each filetype's formatter chain and whether it can run, see :checkhealth pde.format
function M.check_health()
    vim.health.start("formatters by filetype")
    local fts = vim.tbl_keys(vim.tbl_extend("force", defaults.formatters_by_ft, overrides.formatters_by_ft))
    table.sort(fts)
    for _, ft in ipairs(fts) do
        local names = lookup("formatters_by_ft", ft)
        local source = overrides.formatters_by_ft[ft] ~= nil and " (override)" or ""
        if not names or #names == 0 then
            vim.health.info(("%s: disabled%s"):format(ft, source))
        else
            -- each formatter with the binary it resolves to, or the reason it cannot run
            local chain, problems = {}, {}
            for _, name in ipairs(names) do
                local cmd = lookup("formatters", name)
                local path = cmd and vim.fn.exepath(cmd[1]) or ""
                if not cmd then
                    table.insert(problems, ("'%s' is not configured"):format(name))
                elseif path == "" then
                    table.insert(problems, ("'%s' not found"):format(cmd[1]))
                end
                table.insert(chain, path == "" and name or ("%s (%s)"):format(name, path))
            end
            local line = ("%s: %s%s"):format(ft, table.concat(chain, " -> "), source)
            if #problems == 0 then
                vim.health.ok(line)
            else
                vim.health.error(("%s, %s"):format(line, table.concat(problems, ", ")))
            end
        end
    end
end

M._internal = {
    apply_diff = apply_diff,
    ---Forget all configuration.
    reset = function()
        defaults = { formatters = {}, formatters_by_ft = {} }
        overrides = { formatters = {}, formatters_by_ft = {} }
    end,
}

return M
