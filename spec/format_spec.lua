local format = require("pde.format")

local apply_diff = format._internal.apply_diff

-- filetype the fake formatters below are registered for
local test_ft = "format_test"
local timeout_ms = 2000

---@param buf integer
---@return string[]
local function lines(buf) return vim.api.nvim_buf_get_lines(buf, 0, -1, false) end

---@param buf integer
---@param ns integer
---@param row integer 0-based
---@param col integer 0-based
---@return integer id
local function mark(buf, ns, row, col) return vim.api.nvim_buf_set_extmark(buf, ns, row, col, {}) end

---@param buf integer
---@param ns integer
---@param id integer
---@return integer[] { row, col }
local function mark_pos(buf, ns, id) return vim.api.nvim_buf_get_extmark_by_id(buf, ns, id, {}) end

---A shell snippet as a formatter command; it reads the buffer on stdin.
---@param script string
---@param ... string extra arguments, available as $1, $2, ... in the script
---@return string[]
local function sh(script, ...) return { "sh", "-c", script, "sh", ... } end

---Configure a shell snippet as the only formatter of test_ft.
---@param script string
---@param ... string
local function fake_formatter(script, ...)
    format.setup({ formatters = { fake = sh(script, ...) }, formatters_by_ft = { [test_ft] = { "fake" } } })
end

describe("format", function()
    local root
    local ns = vim.api.nvim_create_namespace("format_spec")
    local notifications
    local original_notify = vim.notify

    before_each(function()
        root = vim.fn.tempname()
        vim.fn.mkdir(root, "p")
        root = assert(vim.uv.fs_realpath(root))
        notifications = {}
        ---@diagnostic disable-next-line: duplicate-set-field
        vim.notify = function(msg, level) table.insert(notifications, { msg = msg, level = level }) end
    end)

    after_each(function()
        vim.notify = original_notify
        format._internal.reset()
        vim.cmd("silent! %bwipeout!")
        vim.fn.delete(root, "rf")
    end)

    ---Open a scratch file under root with the given content and filetype.
    ---@param name string
    ---@param content string[]
    ---@param ft string?
    ---@return integer buf
    local function edit(name, content, ft)
        local path = vim.fs.joinpath(root, name)
        vim.fn.writefile(content, path)
        vim.cmd.edit(vim.fn.fnameescape(path))
        local buf = vim.api.nvim_get_current_buf()
        vim.bo[buf].filetype = ft or test_ft
        return buf
    end

    describe("apply_diff", function()
        it("replaces the buffer content with the new lines", function()
            local buf = edit("a.txt", { "a", "b", "c", "d" })
            local new = { "a", "B", "c", "inserted", "d", "tail" }
            apply_diff(buf, lines(buf), new)
            assert.are.same(new, lines(buf))
        end)

        it("deletes lines, including at the end of the buffer", function()
            local buf = edit("a.txt", { "a", "drop", "b", "c", "drop", "drop" })
            apply_diff(buf, lines(buf), { "a", "b", "c" })
            assert.are.same({ "a", "b", "c" }, lines(buf))
        end)

        it("keeps extmarks on untouched lines", function()
            local buf = edit("a.txt", { "keep me", "change me", "keep me too" })
            local first = mark(buf, ns, 0, 5)
            local last = mark(buf, ns, 2, 5)
            apply_diff(buf, lines(buf), { "keep me", "changed", "keep me too" })
            assert.are.same({ 0, 5 }, mark_pos(buf, ns, first))
            assert.are.same({ 2, 5 }, mark_pos(buf, ns, last))
        end)

        it("only replaces the changed bytes of an edited line", function()
            local buf = edit("a.lua", { "if x then", '        print( "hi" )  -- note', "end" })
            -- on the `--` of the comment, which the edit below only shifts left
            local comment = mark(buf, ns, 1, 23)
            apply_diff(buf, lines(buf), { "if x then", '    print( "hi" )  -- note', "end" })
            assert.are.same({ 1, 19 }, mark_pos(buf, ns, comment))
            assert.are.same("--", lines(buf)[2]:sub(20, 21))
        end)

        it("is undone in one step, apart from the edit before it", function()
            local buf = edit("a.txt", { "one", "two" })
            vim.cmd("normal! Ofirst")
            -- end the undo step like typing does between the edit and :write
            vim.o.undolevels = vim.o.undolevels
            apply_diff(buf, lines(buf), { "FIRST", "one", "TWO" })
            vim.cmd("silent undo")
            assert.are.same({ "first", "one", "two" }, lines(buf))
        end)

        it("leaves an unlisted buffer unlisted", function()
            local buf = edit("a.txt", { "a" })
            vim.bo[buf].buflisted = false
            apply_diff(buf, lines(buf), { "b" })
            assert.is_false(vim.bo[buf].buflisted)
        end)
    end)

    describe("has_formatter", function()
        it("is true for a filetype with a formatter", function()
            fake_formatter("cat")
            assert.is_true(format.has_formatter(edit("a.txt", {})))
        end)

        it("is false for a filetype whose default is disabled by override", function()
            fake_formatter("cat")
            format.override({ formatters_by_ft = { [test_ft] = false } })
            assert.is_false(format.has_formatter(edit("a.txt", {})))
        end)

        it(
            "is false for a filetype without one",
            function() assert.is_false(format.has_formatter(edit("a.txt", {}, "text"))) end
        )
    end)

    describe("format", function()
        it("applies the formatter's output", function()
            fake_formatter("tr a-z A-Z")
            local buf = edit("a.txt", { "hello", "world" })
            format.format(buf, timeout_ms)
            assert.are.same({ "HELLO", "WORLD" }, lines(buf))
            assert.are.same({}, notifications)
        end)

        it("passes the buffer's file path for $FILENAME", function()
            fake_formatter('cat >/dev/null; echo "$1"', "$FILENAME")
            local buf = edit("a.txt", { "content" })
            format.format(buf, timeout_ms)
            assert.are.same({ vim.fs.joinpath(root, "a.txt") }, lines(buf))
        end)

        it("runs the formatter in neovim's working directory outside of a repository", function()
            fake_formatter("cat >/dev/null; pwd -P")
            local buf = edit("a.txt", { "content" })
            format.format(buf, timeout_ms)
            assert.are.same({ vim.uv.fs_realpath(vim.fn.getcwd()) }, lines(buf))
        end)

        it("runs the formatter in the repository root, where its ignore files are", function()
            fake_formatter("cat >/dev/null; pwd -P")
            vim.fn.mkdir(vim.fs.joinpath(root, ".git"), "p")
            vim.fn.mkdir(vim.fs.joinpath(root, "sub"), "p")
            local buf = edit("sub/a.txt", { "content" })
            format.format(buf, timeout_ms)
            assert.are.same({ root }, lines(buf))
        end)

        it("treats CRLF output as plain line breaks", function()
            fake_formatter("printf 'keep\\r\\nCHANGED\\r\\n'")
            local buf = edit("a.txt", { "keep", "change" })
            local kept = mark(buf, ns, 0, 2)
            format.format(buf, timeout_ms)
            assert.are.same({ "keep", "CHANGED" }, lines(buf))
            assert.are.same({ 0, 2 }, mark_pos(buf, ns, kept))
        end)

        it("does not touch the buffer when nothing changed", function()
            fake_formatter("cat")
            local buf = edit("a.txt", { "same" })
            local tick = vim.b[buf].changedtick
            format.format(buf, timeout_ms)
            assert.are.equal(tick, vim.b[buf].changedtick)
        end)

        it("keeps the buffer and reports when the formatter fails", function()
            fake_formatter("echo garbage; echo broken >&2; exit 2")
            local buf = edit("a.txt", { "original" })
            format.format(buf, timeout_ms)
            assert.are.same({ "original" }, lines(buf))
            assert.are.equal(vim.log.levels.ERROR, notifications[1].level)
            assert.truthy(notifications[1].msg:find("broken", 1, true))
        end)

        it("reports the exit code when the formatter fails silently", function()
            fake_formatter("exit 3")
            local buf = edit("a.txt", { "original" })
            format.format(buf, timeout_ms)
            assert.truthy(notifications[1].msg:find("exit code 3", 1, true))
        end)

        it("keeps the buffer when the formatter is killed by a signal mid-output", function()
            -- the killed process exits with code 0, only its signal tells it apart from success
            fake_formatter("echo partial; kill -9 $$")
            local buf = edit("a.txt", { "original", "content" })
            format.format(buf, timeout_ms)
            assert.are.same({ "original", "content" }, lines(buf))
            assert.are.equal(vim.log.levels.ERROR, notifications[1].level)
            assert.truthy(notifications[1].msg:find("signal 9", 1, true))
        end)

        it("does not run a formatter that needs a file name on an unnamed buffer", function()
            fake_formatter('cat >/dev/null; echo "$1"', "$FILENAME")
            vim.cmd.enew()
            local buf = vim.api.nvim_get_current_buf()
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "original" })
            vim.bo[buf].filetype = test_ft
            format.format(buf, timeout_ms)
            assert.are.same({ "original" }, lines(buf))
            assert.are.equal(vim.log.levels.WARN, notifications[1].level)
        end)

        it("leaves a non-modifiable buffer alone", function()
            fake_formatter("tr a-z A-Z")
            local buf = edit("a.txt", { "original" })
            vim.bo[buf].modifiable = false
            format.format(buf, timeout_ms)
            assert.are.same({ "original" }, lines(buf))
            assert.are.same({}, notifications)
        end)

        it("keeps the buffer when the formatter times out", function()
            fake_formatter("sleep 5")
            local buf = edit("a.txt", { "original" })
            format.format(buf, 100)
            assert.are.same({ "original" }, lines(buf))
            assert.truthy(notifications[1].msg:find("timed out", 1, true))
        end)

        it("keeps the buffer when the formatter prints nothing", function()
            fake_formatter("cat >/dev/null")
            local buf = edit("a.txt", { "original" })
            format.format(buf, timeout_ms)
            assert.are.same({ "original" }, lines(buf))
        end)

        it("warns when the formatter is not installed", function()
            format.setup({
                formatters = { missing = { "no-such-formatter" } },
                formatters_by_ft = { [test_ft] = { "missing" } },
            })
            local buf = edit("a.txt", { "original" })
            format.format(buf, timeout_ms)
            assert.are.same({ "original" }, lines(buf))
            assert.are.equal(vim.log.levels.WARN, notifications[1].level)
        end)

        it("reports a formatter name that is not configured", function()
            format.setup({ formatters_by_ft = { [test_ft] = { "nope" } } })
            local buf = edit("a.txt", { "original" })
            format.format(buf, timeout_ms)
            assert.are.same({ "original" }, lines(buf))
            assert.truthy(notifications[1].msg:find("nope", 1, true))
        end)

        it("feeds each formatter's output to the next one", function()
            format.setup({
                formatters = { upper = sh("tr a-z A-Z"), exclaim = sh("sed 's/$/!/'") },
                formatters_by_ft = { [test_ft] = { "upper", "exclaim" } },
            })
            local buf = edit("a.txt", { "hello", "world" })
            format.format(buf, timeout_ms)
            assert.are.same({ "HELLO!", "WORLD!" }, lines(buf))
        end)

        it("keeps the buffer when a later formatter in the chain fails", function()
            format.setup({
                formatters = { upper = sh("tr a-z A-Z"), broken = sh("exit 1") },
                formatters_by_ft = { [test_ft] = { "upper", "broken" } },
            })
            local buf = edit("a.txt", { "original" })
            format.format(buf, timeout_ms)
            assert.are.same({ "original" }, lines(buf))
        end)

        it("lets stylua resolve .editorconfig next to the file", function()
            format.setup({
                formatters = {
                    stylua = { "stylua", "--search-parent-directories", "--stdin-filepath", "$FILENAME", "-" },
                },
                formatters_by_ft = { lua = { "stylua" } },
            })
            vim.fn.writefile(
                { "root = true", "[*]", "indent_style = space", "indent_size = 2" },
                root .. "/.editorconfig"
            )
            local buf = edit("a.lua", { "if x then", "        print( 'hi' )", "end" }, "lua")
            format.format(buf, timeout_ms)
            assert.are.same({ "if x then", '  print("hi")', "end" }, lines(buf))
        end)
    end)

    describe("override", function()
        ---@param buf integer
        ---@return string
        local function formatted(buf)
            format.format(buf, timeout_ms)
            return lines(buf)[1]
        end

        local defaults = {
            formatters = { default = sh("echo default"), other = sh("echo other") },
            formatters_by_ft = { [test_ft] = { "default" }, other_ft = { "other" } },
        }
        local project = {
            formatters = { project = sh("echo project") },
            formatters_by_ft = { [test_ft] = { "project" } },
        }

        it("wins over setup when called after it", function()
            format.setup(defaults)
            format.override(project)
            assert.are.equal("project", formatted(edit("a.txt", { "x" })))
        end)

        it("wins over setup when called before it, as .nvim.lua is at startup", function()
            format.override(project)
            format.setup(defaults)
            assert.are.equal("project", formatted(edit("a.txt", { "x" })))
        end)

        it("leaves the keys it does not mention alone", function()
            format.override(project)
            format.setup(defaults)
            assert.are.equal("other", formatted(edit("b.txt", { "x" }, "other_ft")))
        end)

        it("can redefine a default formatter's command", function()
            format.setup(defaults)
            format.override({ formatters = { default = sh("echo redefined") } })
            assert.are.equal("redefined", formatted(edit("a.txt", { "x" })))
        end)

        it("replaces a key from an earlier override whole", function()
            format.setup(defaults)
            format.override({ formatters_by_ft = { [test_ft] = { "default", "other" } } })
            format.override(project)
            assert.are.equal("project", formatted(edit("a.txt", { "x" })))
        end)
    end)

    describe("check_health", function()
        local original_health = vim.health
        local report

        before_each(function()
            report = {}
            local function record(kind)
                return function(msg) table.insert(report, kind .. " " .. msg) end
            end
            ---@diagnostic disable-next-line: missing-fields
            vim.health = { start = function() end, ok = record("ok"), info = record("info"), error = record("error") }
        end)

        after_each(function() vim.health = original_health end)

        it("reports each filetype's chain, sorted, and what keeps it from running", function()
            format.setup({
                formatters = { upper = sh("tr a-z A-Z"), missing = { "no-such-formatter" }, empty = {} },
                formatters_by_ft = { b_ft = { "upper", "missing" }, a_ft = { "upper" }, c_ft = { "upper" }, e_ft = {} },
            })
            format.override({ formatters_by_ft = { c_ft = false, d_ft = { "nope", "empty" } } })
            format.check_health()
            -- where sh lives depends on the environment, only check that it is an absolute path
            local normalized = vim.tbl_map(function(line) return (line:gsub("%(/[^)]*/sh%)", "(/.../sh)")) end, report)
            assert.are.same({
                "ok a_ft: upper (/.../sh)",
                "error b_ft: upper (/.../sh) -> missing, 'no-such-formatter' not found",
                "info c_ft: disabled (override)",
                "error d_ft: nope -> empty (override), 'nope' is not configured, 'empty' is not configured",
                "info e_ft: disabled",
            }, normalized)
        end)
    end)
end)
