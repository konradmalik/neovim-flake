local bufdir = require("pde.bufdir")

---Open a file of the fixture tree in the current window.
---@param root string
---@param relative string
---@return integer buf
local function edit(root, relative)
    vim.cmd.edit(vim.fn.fnameescape(vim.fs.joinpath(root, relative)))
    return vim.api.nvim_get_current_buf()
end

describe("bufdir", function()
    local root
    -- the busted lpath is relative, so the repo cwd has to be put back after each
    -- test or later specs cannot require their modules any more
    local original_cwd

    before_each(function()
        original_cwd = vim.fn.getcwd()
        root = vim.fn.tempname()
        vim.fn.mkdir(vim.fs.joinpath(root, "sub", "deep"), "p")
        for _, f in ipairs({
            "root_level.txt",
            "sub/main.lua",
            "sub/sibling.txt",
            "sub/deep/leaf.txt",
        }) do
            vim.fn.writefile({}, vim.fs.joinpath(root, f))
        end
        -- getcwd() reports the resolved path, which on macOS differs from tempname()
        root = assert(vim.uv.fs_realpath(root))
        vim.cmd.cd(vim.fn.fnameescape(root))
    end)

    after_each(function()
        vim.cmd("silent! bcd!")
        vim.cmd.cd(vim.fn.fnameescape(original_cwd))
        vim.cmd("silent! %bwipeout!")
        vim.fn.delete(root, "rf")
    end)

    describe("buffer_dir", function()
        local buffer_dir = bufdir._internal.buffer_dir

        it("is the directory holding the buffer's file", function()
            local buf = edit(root, "sub/main.lua")
            assert.are.same(vim.fs.joinpath(root, "sub"), buffer_dir(buf))
        end)

        it("is nil for an unnamed buffer", function()
            vim.cmd.enew()
            assert.is_nil(buffer_dir(vim.api.nvim_get_current_buf()))
        end)

        it("is nil for a special buffer", function()
            local buf = edit(root, "sub/main.lua")
            vim.bo[buf].buftype = "nofile"
            assert.is_nil(buffer_dir(buf))
        end)

        -- :bcd would fail with E344 and the error would escape the mapping
        it("is nil for a new file whose parent directory does not exist yet", function()
            local buf = edit(root, "nosuchdir/deeper/new.txt")
            assert.are.same("", vim.bo[buf].buftype)
            assert.is_nil(buffer_dir(buf))
        end)
    end)

    describe("use", function()
        it("points the cwd at the buffer's own directory", function()
            local buf = edit(root, "sub/main.lua")
            assert.is_true(bufdir.use(buf))
            assert.are.same(vim.fs.joinpath(root, "sub"), vim.fn.getcwd())
        end)

        it("makes file completion resolve against the buffer, not the project root", function()
            local buf = edit(root, "sub/main.lua")
            assert.are.same({ "sub/" }, vim.fn.getcompletion("s", "file"))

            bufdir.use(buf)
            assert.are.same({ "sibling.txt" }, vim.fn.getcompletion("s", "file"))
            assert.are.same({ "./deep/", "./main.lua", "./sibling.txt" }, vim.fn.getcompletion("./", "file"))
            assert.are.same({ "../root_level.txt", "../sub/" }, vim.fn.getcompletion("../", "file"))
        end)

        it("restores the cwd when insert mode ends", function()
            local buf = edit(root, "sub/main.lua")
            bufdir.use(buf)

            vim.api.nvim_exec_autocmds("InsertLeave", { buffer = buf })
            assert.are.same(root, vim.fn.getcwd())
            assert.are.same(0, vim.fn.haslocaldir(-1, -1, buf))
        end)

        -- :bcd is documented for pinning a buffer to its project root, so a swap must
        -- hand that back rather than unset it, see :h project-dir
        it("puts back a pre-existing buffer-local directory", function()
            local buf = edit(root, "sub/main.lua")
            vim.cmd.bcd(vim.fn.fnameescape(root))

            bufdir.use(buf)
            assert.are.same(vim.fs.joinpath(root, "sub"), vim.fn.getcwd())

            vim.api.nvim_exec_autocmds("InsertLeave", { buffer = buf })
            assert.are.same(root, vim.fn.getcwd())
            assert.are.same(1, vim.fn.haslocaldir(-1, -1, buf))
        end)

        -- re-triggering completion to descend a level must not save the swapped-in
        -- directory as the one to restore, which would strand the buffer in it
        it("keeps the original directory when re-triggered while swapped", function()
            local buf = edit(root, "sub/main.lua")
            bufdir.use(buf)
            assert.is_true(bufdir.use(buf))
            assert.are.same(vim.fs.joinpath(root, "sub"), vim.fn.getcwd())

            vim.api.nvim_exec_autocmds("InsertLeave", { buffer = buf })
            assert.are.same(root, vim.fn.getcwd())
            assert.are.same(0, vim.fn.haslocaldir(-1, -1, buf))
        end)

        -- getcwd() reports the window-local directory for a buffer that has none of
        -- its own, which must not be handed back as if it were a bcd
        it("does not turn a window-local directory into a buffer-local one", function()
            local buf = edit(root, "sub/main.lua")
            local deep = vim.fs.joinpath(root, "sub", "deep")
            vim.cmd.lcd(vim.fn.fnameescape(deep))

            bufdir.use(buf)
            vim.api.nvim_exec_autocmds("InsertLeave", { buffer = buf })
            assert.are.same(0, vim.fn.haslocaldir(-1, -1, buf))
            assert.are.same(deep, vim.fn.getcwd())
        end)

        it("leaves the cwd alone for a buffer with no usable directory", function()
            vim.cmd.enew()
            local buf = vim.api.nvim_get_current_buf()

            assert.is_false(bufdir.use(buf))
            assert.are.same(root, vim.fn.getcwd())
        end)

        it("handles a directory containing % and # unescaped", function()
            local odd = vim.fs.joinpath(root, "sub", "we%ird #dir")
            vim.fn.mkdir(odd, "p")
            vim.fn.writefile({}, vim.fs.joinpath(odd, "x.txt"))

            local buf = edit(root, "sub/we%ird #dir/x.txt")
            assert.is_true(bufdir.use(buf))
            assert.are.same(odd, vim.fn.getcwd())
            assert.are.same({ "x.txt" }, vim.fn.getcompletion("x", "file"))
        end)
    end)

    describe("restore", function()
        it("puts the cwd back without waiting for insert mode to end", function()
            local buf = edit(root, "sub/main.lua")
            bufdir.use(buf)

            bufdir.restore(buf)
            assert.are.same(root, vim.fn.getcwd())
            assert.are.same(0, vim.fn.haslocaldir(-1, -1, buf))
        end)

        it("puts back a pre-existing buffer-local directory", function()
            local buf = edit(root, "sub/main.lua")
            vim.cmd.bcd(vim.fn.fnameescape(root))
            bufdir.use(buf)

            bufdir.restore(buf)
            assert.are.same(root, vim.fn.getcwd())
            assert.are.same(1, vim.fn.haslocaldir(-1, -1, buf))
        end)

        -- the mapping calls this unconditionally, so it must not clear a project-dir
        -- bcd that no swap of ours replaced
        it("leaves a directory it did not swap in alone", function()
            local buf = edit(root, "sub/main.lua")
            local deep = vim.fs.joinpath(root, "sub", "deep")
            vim.cmd.bcd(vim.fn.fnameescape(deep))

            bufdir.restore(buf)
            assert.are.same(deep, vim.fn.getcwd())
            assert.are.same(1, vim.fn.haslocaldir(-1, -1, buf))
        end)

        -- switching between the two mappings mid-insert leaves a second InsertLeave
        -- autocmd behind, which must not undo the swap the later one put in place
        it("allows swapping in again afterwards", function()
            local buf = edit(root, "sub/main.lua")
            bufdir.use(buf)
            bufdir.restore(buf)

            assert.is_true(bufdir.use(buf))
            assert.are.same(vim.fs.joinpath(root, "sub"), vim.fn.getcwd())

            vim.api.nvim_exec_autocmds("InsertLeave", { buffer = buf })
            assert.are.same(root, vim.fn.getcwd())
            assert.are.same(0, vim.fn.haslocaldir(-1, -1, buf))
        end)
    end)
end)
