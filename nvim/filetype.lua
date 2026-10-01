-- #!/usr/bin/env nix-shell
-- #!nix-shell -p python3 -i python3
---@param buf integer
---@return string?
---@return fun(buf: integer)?
local function nix_hashbang_filetype(_, buf)
    local first = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1]
    if not first or first:sub(1, 2) ~= "#!" then return end

    -- `-S` is tried first: [%w-]+ would otherwise capture it as the tool
    local tool = first:match("^#!%s*/usr/bin/env%s+%-S%s+([%w-]+)") or first:match("^#!%s*/usr/bin/env%s+([%w-]+)")

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
        -- extensionless files and .sh are the only cases extension detection gets wrong
        ["[^.]+"] = nix_hashbang_filetype,
        [".+%.sh"] = nix_hashbang_filetype,
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
