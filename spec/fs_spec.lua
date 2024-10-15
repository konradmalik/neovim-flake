local fs = require("pde.fs")

describe("fs module", function()
    it("returns executables from path", function()
        -- act
        local actual = fs.path_executable("sh")

        -- assert
        actual = assert(actual)
        assert.is_true(vim.endswith(actual, "/sh"))
    end)

    it("returns executable from path when it exists", function()
        -- act
        local actual = fs.from_path_or_default("sh", "default")

        -- assert
        actual = assert(actual)
        assert.is_true(vim.endswith(actual, "/sh"))
    end)

    it("returns default when not in path", function()
        -- act
        local actual = fs.from_path_or_default("not-in-path", "default")

        -- assert
        assert.are.same("default", actual)
    end)
end)
