---Inline image previews on top of `vim.ui.img` (kitty graphics protocol).
---
---1. `vim.ui.img` positions an image with an absolute `ESC[row;colH`, and nvim
---   wraps every `nvim_ui_send` payload in a tmux passthrough, which tmux
---   forwards verbatim. The coordinates are therefore host-absolute and know
---   nothing about the status line or the pane offset; `tmux_offset` corrects
---   that, and is the only tmux-specific thing here.
---2. Only PNG travels over the protocol -- `vim.ui.img` always transmits with
---   `f=100` -- so everything else is converted on the way in.
---3. Given both `c` and `r` the terminal stretches the image to fill that
---   rectangle, so the box has to carry the image's own aspect ratio.

---@class pde.img
local M = {}

---@class pde.img.Config
---@field width integer max width in cells; the image is fitted inside this box
---@field height integer max height in cells
---@field zindex integer stacking order
---@field raster_width integer pixel width to shrink images down to

---@type pde.img.Config
local config = {
    width = 35,
    height = 15,
    zindex = 50,
    raster_width = 800,
}

---The one image we may have on screen.
local state = {
    ---@type integer? id returned by `vim.ui.img.set`
    id = nil,
    ---@type string? source of the image on screen
    src = nil,
    ---@type vim.ui.img.Opts? opts it was placed with
    opts = nil,
    ---@type string? source we last decided to show; makes a slow fetch a no-op
    want = nil,
}

---@type table<string, string> source -> PNG bytes
local cache = {}

---@type { row: integer, col: integer, screen: string }? cached, see `tmux_offset`
local offset = nil

local augroup = vim.api.nvim_create_augroup("pde_img", { clear = true })

local TMUX_FORMAT = "#{client_height} #{window_height} #{status-position} "
    .. "#{pane_top} #{pane_left}"

---Rows and columns the host terminal adds before nvim's own grid origin.
---
---`pane_top` is relative to the window area, which excludes the status line, so
---those rows are added back when the status bar sits on top.
---@param stdout string output of `TMUX_FORMAT`
---@return integer row, integer col
local function parse_offset(stdout)
    local client_h, window_h, position, top, left = stdout:match("(%d+) (%d+) (%a+) (%d+) (%d+)")
    if not client_h then return 0, 0 end

    -- every captured group but `position` matched `%d+`, so all of these convert
    ---@param digits string
    ---@return integer
    local function int(digits) return assert(tonumber(digits)) end

    return int(top) + (position == "top" and int(client_h) - int(window_h) or 0), int(left)
end

---@return { row: integer, col: integer }
local function tmux_offset()
    -- keyed on the screen size, so a resize while another buffer is current
    -- cannot leave a stale offset behind
    local screen = vim.o.columns .. "x" .. vim.o.lines
    if offset and offset.screen == screen then return offset end

    local row, col = 0, 0
    if vim.env.TMUX then
        local cmd = { "tmux", "display-message", "-p", "-t", vim.env.TMUX_PANE or "", TMUX_FORMAT }
        row, col = parse_offset(vim.system(cmd):wait().stdout or "")
    end

    offset = { row = row, col = col, screen = screen }
    return offset
end

local PNG_MAGIC = "\137PNG\r\n\26\n"

---Pixel dimensions straight out of the PNG header.
---@param blob string
---@return { w: integer, h: integer }?
local function png_size(blob)
    if blob:sub(1, 8) ~= PNG_MAGIC or blob:sub(13, 16) ~= "IHDR" then return nil end

    local w1, w2, w3, w4, h1, h2, h3, h4 = blob:byte(17, 24)
    if not h4 then return nil end
    return {
        w = w1 * 0x1000000 + w2 * 0x10000 + w3 * 0x100 + w4,
        h = h1 * 0x1000000 + h2 * 0x10000 + h3 * 0x100 + h4,
    }
end

---A terminal cell is about twice as tall as it is wide. Assuming that instead
---of measuring it is what keeps this identical in and out of tmux, and it lands
---well inside the error of rounding to whole cells anyway.
local CELL_ASPECT = 2

---Largest cell box with the image's aspect ratio that fits in `max_w`x`max_h`.
---@param size { w: integer, h: integer } image size in pixels
---@param max_w integer
---@param max_h integer
---@return integer cols, integer rows
local function fit(size, max_w, max_h)
    -- rows are the coarse axis, so settle them first and match the columns to
    -- them; rounding the two independently is what leaves a wide image skewed
    local rows = math.floor(size.h / size.w * max_w / CELL_ASPECT + 0.5)
    rows = math.max(1, math.min(max_h, rows))
    local cols = math.floor(size.w / size.h * rows * CELL_ASPECT + 0.5)
    return math.max(1, math.min(max_w, cols)), rows
end

---@param src string
---@return boolean
local function is_web(src) return src:match("^https?://") ~= nil end

---The source of the markdown image on `line`, resolved relative to `buf`.
---@param line string
---@param buf integer
---@return string?
local function image_src(line, buf)
    -- ![alt](src "optional title"), possibly wrapped in a [link](...)
    local src = line:match("!%[[^%]]*%]%(%s*<?([^%s>%)]+)")
    if not src or is_web(src) then return src end

    src = vim.fs.normalize(src)
    if vim.startswith(src, "/") then return src end

    -- relative sources are relative to the file, not to the cwd
    local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(buf))
    return dir ~= "" and vim.fs.normalize(vim.fs.joinpath(dir, src)) or src
end

---Hand back PNG bytes for `src`, converting whatever it really is.
---@param src string
---@param callback fun(png: string)
local function fetch(src, callback)
    if cache[src] then
        callback(cache[src])
        return
    end

    ---@param blob string raw bytes in any format ImageMagick reads
    local function convert(blob)
        local cmd = {
            "magick",
            -- a density this far above the default only matters for vector
            -- sources, which would otherwise render at their natural size and
            -- then be blown up; the resize below pulls raster ones back down
            "-density",
            "384",
            "-[0]", -- first frame only, or an animation arrives as several PNGs
            "-resize",
            -- a 4000px png is 96MB of base64 down the tty, and nothing on
            -- screen is ever that wide, so shrink everything to something sane
            config.raster_width .. "x>",
            "-depth",
            "8", -- magick defaults to 16, which triples the payload for nothing
            "-strip",
            "png:-",
        }
        vim.system(cmd, { stdin = blob }, function(res)
            if res.code ~= 0 or res.stdout == "" then return end
            cache[src] = res.stdout
            vim.schedule(function() callback(res.stdout) end)
        end)
    end

    if is_web(src) then
        vim.net.request(src, {}, function(err, res)
            if not err and res and res.body then convert(res.body) end
        end)
    else
        convert(vim.fn.readblob(src))
    end
end

---Where to put `blob`, as a box anchored to the top-right of the current window.
---@param blob string
---@param off { row: integer, col: integer }
---@return vim.ui.img.Opts
local function placement(blob, off)
    local win_row, win_col = unpack(vim.api.nvim_win_get_position(0))
    local win_w = vim.api.nvim_win_get_width(0)
    local max_w = math.min(config.width, win_w)
    local max_h = math.min(config.height, vim.api.nvim_win_get_height(0))

    -- With nothing to measure, send a width only and let the terminal work the
    -- rows out; that cannot stretch the image, only overshoot the box.
    local width, height = max_w, nil
    local size = png_size(blob)
    if size then
        width, height = fit(size, max_w, max_h)
    end

    return {
        row = win_row + off.row + 1, -- 1-indexed, unlike the window position
        col = win_col + off.col + win_w - width + 1,
        width = width,
        height = height,
        zindex = config.zindex,
    }
end

---Remove the image on screen, if any.
function M.hide()
    state.want = nil
    if state.id then vim.ui.img.del(state.id) end
    state.id, state.src, state.opts = nil, nil, nil
end

local function refresh()
    local buf = vim.api.nvim_get_current_buf()
    local src = image_src(vim.api.nvim_get_current_line(), buf)
    if not src or (not is_web(src) and vim.fn.filereadable(src) ~= 1) then
        M.hide()
        return
    end

    state.want = src
    fetch(
        src,
        vim.schedule_wrap(function(blob)
            if state.want ~= src then return end

            local opts = placement(blob, tmux_offset())
            if state.src == src and vim.deep_equal(state.opts, opts) then return end

            if state.id then vim.ui.img.del(state.id) end
            state.id, state.src, state.opts = vim.ui.img.set(blob, opts), src, opts
        end)
    )
end

---Preview the image under the cursor in `buf`.
---@param buf? integer buffer to attach to (default: the current buffer)
function M.attach(buf)
    buf = buf or 0

    vim.api.nvim_create_autocmd("CursorHold", {
        group = augroup,
        buffer = buf,
        callback = function() refresh() end,
    })

    vim.api.nvim_create_autocmd("CursorMoved", {
        group = augroup,
        buffer = buf,
        callback = function(args)
            local src = image_src(vim.api.nvim_get_current_line(), args.buf)
            if state.src and src ~= state.src then M.hide() end
        end,
    })

    vim.api.nvim_create_autocmd(
        { "BufLeave", "WinLeave", "InsertEnter", "TabLeave", "VimResized", "FocusLost" },
        {
            group = augroup,
            buffer = buf,
            callback = function() M.hide() end,
        }
    )
end

---exposed so `spec/img_spec.lua` can reach them.
---@class pde.img.Internal
M._internal = {
    fit = fit,
    image_src = image_src,
    parse_offset = parse_offset,
    placement = placement,
    png_size = png_size,
}

return M
