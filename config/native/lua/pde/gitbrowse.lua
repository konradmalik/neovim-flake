---NOTE: stolen from https://github.com/folke/snacks.nvim/blob/main/lua/snacks/gitbrowse.lua

---@class gitbrowse
---@hide
---@overload fun(opts?: gitbrowse.Config)
local M = setmetatable({}, {
    __call = function(t, ...) return t.open(...) end,
})

---@class gitbrowse.Config
local defaults = {
    ---function that transforms URL in some custom way
    ---@param url string
    ---@return string
    url_transform = function(url) return url end,

    -- patterns to transform remotes to an actual URL
    -- stylua: ignore
    patterns = {
      { "^(https?://.*)%.git$"              , "%1" },
      { "^git@(.+):(.+)%.git$"              , "https://%1/%2" },
      { "^git@(.+):(.+)$"                   , "https://%1/%2" },
      { "^git@(.+)/(.+)$"                   , "https://%1/%2" },
      { "^ssh://git@(.*)$"                  , "https://%1" },
      { "^ssh://([^:/]+)(:%d+)/(.*)$"       , "https://%1/%3" },
      { "^ssh://([^/]+)/(.*)$"              , "https://%1/%2" },
      { "ssh%.dev%.azure%.com/v3/(.*)/(.*)$", "dev.azure.com/%1/_git/%2" },
      { "^https://%w*@(.*)"                 , "https://%1" },
      { "^git@(.*)"                         , "https://%1" },
      { ":%d+"                              , "" },
      { "%.git$"                            , "" },
  },
}

---@param remote string
---@param opts? gitbrowse.Config
local function get_url(remote, opts)
    opts = vim.tbl_deep_extend("force", defaults, opts or {})
    local ret = remote
    for _, pattern in ipairs(opts.patterns) do
        ret = ret:gsub(pattern[1], pattern[2])
    end
    return ret:find("https://") == 1 and ret or ("https://%s"):format(ret)
end

---@param opts? gitbrowse.Config
function M.open(opts)
    opts = vim.tbl_deep_extend("force", defaults, opts or {})
    local proc = vim.system({ "git", "remote", "-v" }, { text = true }):wait()
    if proc.code ~= 0 then
        return vim.notify(
            "Failed to get git remotes",
            vim.log.levels.ERROR,
            { title = "Git Browse" }
        )
    end
    local lines = vim.split(proc.stdout, "\n")

    proc = vim.system({ "git", "rev-parse", "--abbrev-ref", "HEAD" }):wait()
    if proc.code ~= 0 then
        return vim.notify(
            "Failed to get current branch",
            vim.log.levels.ERROR,
            { title = "Git Browse" }
        )
    end
    local branch = proc.stdout:gsub("\n", "") or "HEAD"

    proc = vim.system({ "git", "ls-files", "--full-name", vim.fn.expand("%") }):wait()
    if proc.code ~= 0 then
        return vim.notify(
            "Failed to get current file",
            vim.log.levels.WARN,
            { title = "Git Browse" }
        )
    end
    local file = proc.stdout:gsub("\n", "")

    local remotes = {} ---@type {name:string, url:string}[]

    for _, line in ipairs(lines) do
        local name, remote = line:match("(%S+)%s+(%S+)%s+%(fetch%)")
        if name and remote then
            local url = get_url(remote, opts)
            if url:find("github") then url = ("%s/tree/%s"):format(url, branch) end
            if url:find("gitlab") then url = ("%s/-/blob/%s"):format(url, branch) end
            if url then
                url = opts.url_transform(url)

                table.insert(remotes, {
                    name = name,
                    url = url,
                })
            end
        end
    end

    local function open(remote)
        if remote then
            local full_url = remote.url
            if file then full_url = remote.url .. "/" .. file end
            vim.notify(
                ("Opening [%s](%s)"):format(remote.name, full_url),
                vim.log.levels.INFO,
                { title = "Git Browse" }
            )
            vim.ui.open(full_url)
        end
    end

    if #remotes == 0 then
        return vim.notify("No git remotes found", vim.log.levels.ERROR, { title = "Git Browse" })
    elseif #remotes == 1 then
        return open(remotes[1])
    end

    vim.ui.select(remotes, {
        prompt = "Select remote to browse",
        format_item = function(item)
            return item.name .. (" "):rep(8 - #item.name) .. " 🔗 " .. item.url
        end,
    }, open)
end

return M
