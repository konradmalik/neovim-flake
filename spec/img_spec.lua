local img = require("pde.img")
local fit = img._internal.fit
local image_src = img._internal.image_src
local parse_offset = img._internal.parse_offset
local placement = img._internal.placement
local png_size = img._internal.png_size

---A PNG header is all `png_size` reads, so that is all a fixture needs.
---@param w integer
---@param h integer
---@return string
local function png(w, h)
    ---@param n integer
    local function be32(n)
        return string.char(
            math.floor(n / 0x1000000) % 0x100,
            math.floor(n / 0x10000) % 0x100,
            math.floor(n / 0x100) % 0x100,
            n % 0x100
        )
    end
    return "\137PNG\r\n\26\n" .. be32(13) .. "IHDR" .. be32(w) .. be32(h)
end

describe("png_size", function()
    it(
        "reads the dimensions out of the header",
        function() assert.are.same({ w = 800, h = 154 }, png_size(png(800, 154))) end
    )

    it(
        "reads dimensions that need more than one byte",
        function() assert.are.same({ w = 1920, h = 1080 }, png_size(png(1920, 1080))) end
    )

    it("rejects anything that is not a PNG", function()
        assert.is_nil(png_size("<svg xmlns='http://www.w3.org/2000/svg'></svg>"))
        assert.is_nil(png_size(""))
        assert.is_nil(png_size(png(8, 8):sub(1, 20)))
    end)
end)

describe("fit", function()
    -- ghostty stretches to fill when given both a column and a row count, so
    -- the box has to carry the image's aspect ratio itself
    local cell_w, cell_h = 21, 43 -- a real ghostty cell, to score the result

    ---@return number ratio of the resulting box to the image's own
    local function skew(px_w, px_h, max_w, max_h)
        local cols, rows = fit({ w = px_w, h = px_h }, max_w, max_h)
        return ((cols * cell_w) / (rows * cell_h)) / (px_w / px_h)
    end

    it("keeps the aspect ratio within the error of a guessed cell", function()
        for _, size in ipairs({
            { 800, 154 }, -- a CI badge
            { 1920, 1080 },
            { 600, 900 },
            { 64, 64 },
        }) do
            assert.is_true(math.abs(skew(size[1], size[2], 35, 15) - 1) < 0.05)
        end
    end)

    it(
        "fits a wide image to the box width",
        function() assert.are.same({ 31, 3 }, { fit({ w = 800, h = 154 }, 35, 15) }) end
    )

    it(
        "fits a tall image to the box height",
        function() assert.are.same({ 10, 15 }, { fit({ w = 60, h = 180 }, 35, 15) }) end
    )

    it("never exceeds the box", function()
        local cols, rows = fit({ w = 4000, h = 4000 }, 35, 15)
        assert.is_true(cols <= 35 and rows <= 15)
    end)

    it("never collapses to nothing", function()
        local cols, rows = fit({ w = 4000, h = 1 }, 35, 15)
        assert.is_true(cols >= 1 and rows >= 1)
    end)
end)

describe("parse_offset", function()
    -- fields are: client_height window_height status-position pane_top pane_left
    it(
        "adds the status lines when the bar is on top",
        function() assert.are.same({ 1, 0 }, { parse_offset("24 23 top 0 0") }) end
    )

    it(
        "ignores the status lines when the bar is on the bottom",
        function() assert.are.same({ 0, 0 }, { parse_offset("24 23 bottom 0 0") }) end
    )

    it(
        "counts a multi-line status bar",
        function() assert.are.same({ 2, 0 }, { parse_offset("24 22 top 0 0") }) end
    )

    it(
        "adds the pane offset on top of the status lines",
        function() assert.are.same({ 14, 40 }, { parse_offset("24 23 top 13 40") }) end
    )

    it(
        "falls back to the grid origin when tmux says nothing",
        function() assert.are.same({ 0, 0 }, { parse_offset("") }) end
    )
end)

describe("image_src", function()
    it(
        "finds a plain markdown image",
        function()
            assert.are.equal("https://x.dev/a.png", image_src("![alt](https://x.dev/a.png)", 0))
        end
    )

    it("finds an image wrapped in a link, as CI badges are", function()
        local line = "[![Status](https://x.dev/b.svg)](https://x.dev/runs)"
        assert.are.equal("https://x.dev/b.svg", image_src(line, 0))
    end)

    it(
        "ignores a title after the source",
        function()
            assert.are.equal("https://x.dev/a.png", image_src('![a](https://x.dev/a.png "t")', 0))
        end
    )

    it("returns nil for a line with no image", function()
        assert.is_nil(image_src("[a link](https://x.dev)", 0))
        assert.is_nil(image_src("", 0))
    end)

    it("resolves a relative source against the file, not the cwd", function()
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_name(buf, "/tmp/pde-img-spec/docs/readme.md")

        assert.are.equal("/tmp/pde-img-spec/docs/img/a.png", image_src("![a](img/a.png)", buf))
        assert.are.equal("/tmp/pde-img-spec/img/a.png", image_src("![a](../img/a.png)", buf))
        assert.are.equal("/elsewhere/a.png", image_src("![a](/elsewhere/a.png)", buf))

        vim.api.nvim_buf_delete(buf, { force = true })
    end)
end)

describe("placement", function()
    -- `vim.ui.img.Opts` is a nightly-only class and busted runs stable nvim, so
    -- these compare the whole table rather than naming a field it cannot see
    local blob = png(800, 154)

    ---@return integer row, integer col, integer width, integer height
    local function window()
        local row, col = unpack(vim.api.nvim_win_get_position(0))
        return row, col, vim.api.nvim_win_get_width(0), vim.api.nvim_win_get_height(0)
    end

    before_each(function()
        -- the expected boxes below assume the default 35x15 is what binds
        local _, _, width, height = window()
        assert.is_true(width >= 35 and height >= 15)
    end)

    it("offsets past the status bar and the pane", function()
        local win_row, win_col, win_width = window()

        assert.are.same({
            row = win_row + 1 + 1, -- one status line, then nvim's own grid origin
            col = win_col + 40 + win_width - 31 + 1,
            width = 31,
            height = 3,
            zindex = 50,
        }, placement(blob, { row = 1, col = 40 }))
    end)

    it("anchors to the right edge of the window", function()
        local win_row, win_col, win_width = window()

        assert.are.same({
            row = win_row + 1,
            col = win_col + win_width - 31 + 1,
            width = 31,
            height = 3,
            zindex = 50,
        }, placement(blob, { row = 0, col = 0 }))
    end)

    it("sends no height for a blob it cannot measure", function()
        local win_row, win_col, win_width = window()

        assert.are.same({
            row = win_row + 1,
            col = win_col + win_width - 35 + 1,
            width = 35,
            zindex = 50,
        }, placement("not a png", { row = 0, col = 0 }))
    end)
end)
