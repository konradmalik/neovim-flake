---@return string
local function get_dir()
    local mktemp_obj = vim.system({ "mktemp", "-d", "-t", "neovim-flake-XXXXXX" }, { text = true })
        :wait()

    if mktemp_obj.code ~= 0 then error("cannot create tmpdir") end

    return vim.fn.split(mktemp_obj.stdout, "\n")[1]
end

---@param dir string
local function clear(dir) os.execute("rm -rf " .. dir) end

-- to avoid writing in the real state
---@param dir string
local function fake_stdpath(dir)
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.fn.stdpath = function(what) return vim.fs.joinpath(dir, what) end
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
