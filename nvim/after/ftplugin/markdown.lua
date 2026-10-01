if vim.b.did_md_ftplugin then return end

-- The default `gx`, except that a link which exists relative to this file
-- opens from here rather than from the cwd.
-- Anything else (URLs, ~ and absolute paths, #anchors) is passed through untouched.
vim.keymap.set("n", "gx", function()
    local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
    -- private, but it is what the default `gx` uses
    for _, url in ipairs(require("vim.ui")._get_urls()) do
        local path = vim.fs.joinpath(dir, url)
        local _, err = vim.ui.open(vim.uv.fs_stat(path) and path or url)
        if err then vim.notify(err, vim.log.levels.ERROR) end
    end
end, { buffer = true, desc = "Open link under cursor, relative to this file" })

vim.b.did_md_ftplugin = true
