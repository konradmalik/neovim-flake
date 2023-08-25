-- adapted from https://github.com/akinsho/git-conflict.nvim
local color = require('konrad.git-conflict.colors')
local api = vim.api

--- @class ConflictHighlights
--- @field current string
--- @field incoming string
--- @field ancestor string?

--- @class ConflictPosition
--- @field incoming Range
--- @field middle Range
--- @field current Range

local CURRENT_HL = 'GitConflictCurrent'
local INCOMING_HL = 'GitConflictIncoming'
local ANCESTOR_HL = 'GitConflictAncestor'
local CURRENT_LABEL_HL = 'GitConflictCurrentLabel'
local INCOMING_LABEL_HL = 'GitConflictIncomingLabel'
local ANCESTOR_LABEL_HL = 'GitConflictAncestorLabel'
local PRIORITY = vim.highlight.priorities.user
local NAMESPACE = api.nvim_create_namespace('git-conflict')
local AUGROUP_NAME = 'GitConflictCommands'

local conflict_start = '^<<<<<<<'
local conflict_middle = '^======='
local conflict_end = '^>>>>>>>'
local conflict_ancestor = '^|||||||'

local DEFAULT_CURRENT_BG_COLOR = 4218238  -- #405d7e
local DEFAULT_INCOMING_BG_COLOR = 3229523 -- #314753
local DEFAULT_ANCESTOR_BG_COLOR = 6824314 -- #68217A

local config = {
    highlights = {
        current = 'diffAdded',
        incoming = 'diffChanged',
        ancestor = 'diffRemoved',
    },
    labels = {
        current = '(Current Change)',
        incoming = '(Incoming Change)',
        ancestor = '(Base Change)',
    },
}

---@param name string?
---@return table<string, string>
local function get_hl(name)
    if not name then return {} end
    return api.nvim_get_hl(NAMESPACE, { name = name })
end

---Set an extmark for each section of the git conflict
---@param bufnr integer
---@param hl string
---@param range_start integer
---@param range_end integer
---@return integer? extmark_id
local function hl_range(bufnr, hl, range_start, range_end)
    if not range_start or not range_end then return end
    return api.nvim_buf_set_extmark(bufnr, NAMESPACE, range_start, 0, {
        hl_group = hl,
        hl_eol = true,
        hl_mode = 'combine',
        end_row = range_end,
        priority = PRIORITY,
    })
end

---Add highlights and additional data to each section heading of the conflict marker
---@param bufnr integer
---@param hl_group string
---@param label string
---@param lnum integer
---@return integer extmark id
local function draw_section_label(bufnr, hl_group, label, lnum)
    return api.nvim_buf_set_extmark(bufnr, NAMESPACE, lnum, 0, {
        hl_group = hl_group,
        virt_text = { { label, hl_group } },
        virt_text_pos = 'eol',
        priority = PRIORITY,
    })
end

---Highlight each part of a git conflict i.e. the incoming changes vs the current/HEAD changes
---@param positions table
local function highlight_conflicts(positions)
    local bufnr = api.nvim_get_current_buf()

    for _, position in ipairs(positions) do
        local current_start = position.current.range_start
        local current_end = position.current.range_end
        local incoming_start = position.incoming.range_start
        local incoming_end = position.incoming.range_end

        draw_section_label(bufnr, CURRENT_LABEL_HL, config.labels.current, current_start)
        hl_range(bufnr, CURRENT_LABEL_HL, current_start, current_start + 1)
        hl_range(bufnr, CURRENT_HL, current_start + 1, current_end + 1)
        draw_section_label(bufnr, INCOMING_LABEL_HL, config.labels.incoming, incoming_end)
        hl_range(bufnr, INCOMING_HL, incoming_start, incoming_end)
        hl_range(bufnr, INCOMING_LABEL_HL, incoming_end, incoming_end + 1)

        if not vim.tbl_isempty(position.ancestor) then
            local ancestor_start = position.ancestor.range_start
            local ancestor_end = position.ancestor.range_end
            draw_section_label(bufnr, ANCESTOR_LABEL_HL, config.labels.ancestor, ancestor_start)
            hl_range(bufnr, ANCESTOR_LABEL_HL, ancestor_start, ancestor_start + 1)
            hl_range(bufnr, ANCESTOR_HL, ancestor_start + 1, ancestor_end + 1)
        end
    end
end

---Iterate through the buffer line by line checking there is a matching conflict marker
---when we find a starting mark we collect the position details and add it to a list of positions
---@param lines string[]
---@return boolean
---@return ConflictPosition[]
local function detect_conflicts(lines)
    local positions = {}
    local position, has_start, has_middle, has_ancestor = nil, false, false, false
    for index, line in ipairs(lines) do
        local lnum = index - 1
        if line:match(conflict_start) then
            has_start = true
            position = {
                current = { range_start = lnum, content_start = lnum + 1 },
                middle = {},
                incoming = {},
                ancestor = {},
            }
        end
        if has_start and line:match(conflict_ancestor) then
            has_ancestor = true
            position.ancestor.range_start = lnum
            position.ancestor.content_start = lnum + 1
            position.current.range_end = lnum - 1
            position.current.content_end = lnum - 1
        end
        if has_start and line:match(conflict_middle) then
            has_middle = true
            if has_ancestor then
                position.ancestor.content_end = lnum - 1
                position.ancestor.range_end = lnum - 1
            else
                position.current.range_end = lnum - 1
                position.current.content_end = lnum - 1
            end
            position.middle.range_start = lnum
            position.middle.range_end = lnum + 1
            position.incoming.range_start = lnum + 1
            position.incoming.content_start = lnum + 1
        end
        if has_start and has_middle and line:match(conflict_end) then
            position.incoming.range_end = lnum
            position.incoming.content_end = lnum - 1
            positions[#positions + 1] = position

            position, has_start, has_middle, has_ancestor = nil, false, false, false
        end
    end
    return #positions > 0, positions
end

---@param bufnr integer?
local function clear_highlights(bufnr)
    if bufnr and not api.nvim_buf_is_valid(bufnr) then return end
    bufnr = bufnr or 0
    api.nvim_buf_clear_namespace(bufnr, NAMESPACE, 0, -1)
end

---Get the conflict marker positions for a buffer if any and update the buffers state
---@param bufnr integer?
---@param range_start integer?
---@param range_end integer?
local function draw_buffer(bufnr, range_start, range_end)
    local lines = api.nvim_buf_get_lines(bufnr or 0, range_start or 0, range_end or -1, false)
    local has_conflict, positions = detect_conflicts(lines)

    clear_highlights(bufnr)
    if has_conflict then
        highlight_conflicts(positions)
    end
end

---Derive the colour of the section label highlights based on each sections highlights
---@param highlights ConflictHighlights
local function set_highlights(highlights)
    local current_color = get_hl(highlights.current)
    local incoming_color = get_hl(highlights.incoming)
    local ancestor_color = get_hl(highlights.ancestor)
    local current_bg = current_color.background or DEFAULT_CURRENT_BG_COLOR
    local incoming_bg = incoming_color.background or DEFAULT_INCOMING_BG_COLOR
    local ancestor_bg = ancestor_color.background or DEFAULT_ANCESTOR_BG_COLOR
    local current_label_bg = color.shade_color(current_bg, 30)
    local incoming_label_bg = color.shade_color(incoming_bg, 30)
    local ancestor_label_bg = color.shade_color(ancestor_bg, 30)
    api.nvim_set_hl(0, CURRENT_HL, { background = current_bg, default = true })
    api.nvim_set_hl(0, INCOMING_HL, { background = incoming_bg, default = true })
    api.nvim_set_hl(0, ANCESTOR_HL, { background = ancestor_bg, default = true })
    api.nvim_set_hl(0, CURRENT_LABEL_HL, { background = current_label_bg, default = true })
    api.nvim_set_hl(0, INCOMING_LABEL_HL, { background = incoming_label_bg, default = true })
    api.nvim_set_hl(0, ANCESTOR_LABEL_HL, { background = ancestor_label_bg, default = true })
end

local M = {}

function M.setup(user_config)
    config = vim.tbl_deep_extend('force', config, user_config or {})

    set_highlights(config.highlights)

    api.nvim_create_augroup(AUGROUP_NAME, { clear = true })
    api.nvim_create_autocmd('ColorScheme', {
        group = AUGROUP_NAME,
        callback = function() set_highlights(config.highlights) end,
    })

    api.nvim_create_autocmd({ 'BufReadPost', 'BufWritePost' }, {
        group = AUGROUP_NAME,
        callback = function()
            -- TODO is it worth checking if git repo?
            draw_buffer();
        end,
    })
end

return M
