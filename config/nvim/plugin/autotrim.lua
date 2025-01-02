local trim_is_enabled = true

---@param buf integer
local trim_is_enabled_in_editorconfig = function(buf)
    local ed = vim.b[buf].editorconfig
    if ed then return ed.trim_trailing_whitespace end
    return false
end

vim.api.nvim_create_user_command("AutoTrimToggle", function()
    if trim_is_enabled_in_editorconfig(0) then
        vim.notify(
            "Cannot toggle autotrim because it's forced by editorconfig",
            vim.log.levels.WARN
        )
        return
    end
    trim_is_enabled = not trim_is_enabled
    print("Setting autotrim to: " .. tostring(trim_is_enabled))
end, {
    desc = "Enable/disable autotrimming whitespace on buffer save",
})

---Deletes all trailing whitespace in a file if it's not binary nor a diff.
---@param buf integer
local trim_trailing_whitespace = function(buf)
    if not vim.bo[buf].binary and vim.bo[buf].filetype ~= "diff" then
        local view = vim.fn.winsaveview()
        vim.api.nvim_command("silent! undojoin")
        vim.api.nvim_command("silent keepjumps keeppatterns %s/\\s\\+$//e")
        vim.fn.winrestview(view)
    end
end

local group = vim.api.nvim_create_augroup("personal-autotrim", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
    group = group,
    callback = function(ev)
        if not trim_is_enabled then return end
        local bufnr = ev.buf
        if trim_is_enabled_in_editorconfig(bufnr) then
            -- let native neovim handle it
            return
        end
        trim_trailing_whitespace(bufnr)
    end,
})
