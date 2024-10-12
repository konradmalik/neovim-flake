---@return string
local function get_dir()
    return assert(vim.uv.fs_mkdtemp(vim.uv.os_tmpdir() .. "/git-conflict-nvim-XXXXXX"))
end

---@param dir string
local function clear(dir) os.execute("rm -rf " .. dir) end

-- to avoid writing in the real state
---@param dir string
local function fake_stdpath(dir)
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.fn.stdpath = function(what) return dir .. "/" .. what end
end

describe("paths", function()
    local dir
    before_each(function()
        dir = get_dir()
        fake_stdpath(dir)
    end)
    after_each(function() clear(dir) end)

    it("handles nil by returning state for notes", function()
        -- act
        local actual_path = require("pde.paths").get_notes()

        -- assert
        assert.are.same(dir .. "/state/notes", actual_path)
    end)

    it("handles nil by returning state for spell", function()
        -- act
        local actual_path = require("pde.paths").get_spellfile()

        -- assert
        assert.are.same(dir .. "/state/spell", actual_path)
    end)
end)
