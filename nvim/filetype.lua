-- Neovim resolves a `nix`/`nix-shell` hashbang to filetype "nix", but the body of such a
-- script is written in whatever `-i` (nix-shell) or `-c`/`--command` (nix) names:
--
--   #!/usr/bin/env nix-shell
--   #!nix-shell -p python3 -i python3
--
-- Runs on every buffer, so it bails on the first line whenever it can.
---@param buf integer
---@return string?
---@return fun(buf: integer)?
local function nix_hashbang_filetype(_path, buf)
    local first = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1]
    if not first or first:sub(1, 2) ~= "#!" then return end

    -- `-S` is tried first: [%w-]+ would otherwise capture it as the tool
    local tool = first:match("^#!%s*/usr/bin/env%s+%-S%s+([%w-]+)")
        or first:match("^#!%s*/usr/bin/env%s+([%w-]+)")

    local interpreter_arg
    if tool == "nix-shell" then
        interpreter_arg = { ["-i"] = true }
    elseif tool == "nix" then
        interpreter_arg = { ["-c"] = true, ["--command"] = true }
    else
        return
    end

    -- the hashbang block is contiguous at the top of the file
    local take = false
    for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, 10, false)) do
        if line:sub(1, 2) ~= "#!" then break end
        for word in line:gmatch("%S+") do
            if take then
                -- a quoted `--command 'bash -e'` splits here; the program name is enough
                return vim.filetype.match({
                    contents = { "#!/usr/bin/env " .. word:gsub("^['\"]", "") },
                })
            end
            take = interpreter_arg[word] or false
        end
    end
end

vim.filetype.add({
    pattern = {
        -- ".-" anchors to "^.-$", which matches every path just like "^.*$" does, but is a
        -- distinct key. vim.filetype.add stores patterns as pattern[""]["^"..pat.."$"], so
        -- reusing ".*" here would silently overwrite the catch-all in plugin/bigfile.lua
        -- (plugin files are sourced after this one).
        [".-"] = { nix_hashbang_filetype, { priority = 5 } },
    },
    filename = {
        condarc = "yaml",
        ["composer.lock"] = "json",
        Tiltfile = "python",
    },
    extension = {
        hujson = "hujson",
    },
})
