local opts_with_desc = function(desc) return { desc = "[gitbrowse] " .. desc } end

---@type pde.gitbrowse.Config
local opts = {
    url_transform = function(url)
        if url:find("repositories.gitlab") then url = url:gsub("repositories.", "") end
        return url
    end,
}
vim.keymap.set(
    "n",
    "<leader>go",
    function() require("pde.gitbrowse").open(opts) end,
    opts_with_desc("open current file in the browser")
)
