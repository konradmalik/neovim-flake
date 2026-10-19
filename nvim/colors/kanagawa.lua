-- Kanagawa wave, trimmed down from https://github.com/rebelot/kanagawa.nvim
-- Copyright (c) 2021 Tommaso Laurenzi, MIT License

vim.o.background = "dark"
vim.cmd.highlight("clear")
vim.g.colors_name = "kanagawa"

local c = {
    -- ui
    fg = "#dcd7ba", -- fujiWhite
    fg_dim = "#c8c093", -- oldWhite
    fg_reverse = "#223249", -- waveBlue1
    bg_m3 = "#16161d", -- sumiInk0
    bg = "#1f1f28", -- sumiInk3
    bg_p1 = "#2a2a37", -- sumiInk4
    bg_p2 = "#363646", -- sumiInk5
    special = "#938aa9", -- springViolet1
    nontext = "#54546d", -- sumiInk6
    bg_search = "#2d4f67", -- waveBlue2
    bg_visual = "#223249", -- waveBlue1

    -- syntax
    string = "#98bb6c", -- springGreen
    number = "#d27e99", -- sakuraPink
    constant = "#ffa066", -- surimiOrange
    identifier = "#e6c384", -- carpYellow
    parameter = "#b8b4d0", -- oniViolet2
    fun = "#7e9cd8", -- crystalBlue
    keyword = "#957fb8", -- oniViolet
    operator = "#c0a36e", -- boatYellow2
    preproc = "#e46876", -- waveRed
    type = "#7aa89f", -- waveAqua2
    comment = "#727169", -- fujiGray
    punct = "#9cabca", -- springViolet2
    special1 = "#7fb4ca", -- springBlue
    special2 = "#e46876", -- waveRed
    special3 = "#ff5d62", -- peachRed

    -- vcs
    added = "#76946a", -- autumnGreen
    removed = "#c34043", -- autumnRed
    changed = "#dca561", -- autumnYellow

    -- diff
    diff_add = "#2b3328", -- winterGreen
    diff_delete = "#43242b", -- winterRed
    diff_change = "#252535", -- winterBlue
    diff_text = "#49443c", -- winterYellow

    -- diagnostics
    ok = "#98bb6c", -- springGreen
    error = "#e82424", -- samuraiRed
    warning = "#ff9e3b", -- roninYellow
    info = "#658594", -- dragonBlue
    hint = "#6a9589", -- waveAqua1
}

---@type table<string, vim.api.keyset.highlight>
local hl = {
    -- editor
    ColorColumn = { bg = c.bg_p1 },
    Conceal = { fg = c.special, bold = true },
    CurSearch = { fg = c.fg, bg = c.bg_search, bold = true },
    Cursor = { fg = c.bg, bg = c.fg },
    lCursor = { link = "Cursor" },
    CursorColumn = { link = "CursorLine" },
    CursorLine = { bg = c.bg_p2 },
    Directory = { fg = c.fun },
    DiffAdd = { bg = c.diff_add },
    DiffChange = { bg = c.diff_change },
    DiffDelete = { fg = c.removed, bg = c.diff_delete },
    DiffText = { bg = c.diff_text },
    EndOfBuffer = { fg = c.bg },
    ErrorMsg = { fg = c.error },
    WinSeparator = { fg = c.bg_m3 },
    Folded = { fg = c.special, bg = c.bg_p1 },
    FoldColumn = { fg = c.nontext },
    SignColumn = { fg = c.special },
    IncSearch = { fg = c.fg_reverse, bg = c.warning },
    Substitute = { fg = c.fg, bg = c.removed },
    LineNr = { fg = c.nontext },
    CursorLineNr = { fg = c.warning, bold = true },
    MatchParen = { fg = c.warning, bold = true },
    ModeMsg = { fg = c.warning, bold = true },
    MsgArea = { fg = c.fg_dim },
    MsgSeparator = { fg = c.bg_m3, bg = c.bg_m3 },
    MoreMsg = { fg = c.info },
    NonText = { fg = c.nontext },
    Normal = { fg = c.fg, bg = c.bg },
    NormalNC = { link = "Normal" },
    NormalFloat = { fg = c.fg_dim, bg = c.bg_m3 },
    FloatBorder = { fg = c.nontext, bg = c.bg_m3 },
    FloatTitle = { fg = c.special, bg = c.bg_m3, bold = true },
    FloatFooter = { fg = c.nontext, bg = c.bg_m3 },
    Pmenu = { fg = c.fg, bg = c.fg_reverse },
    PmenuSel = { bg = c.bg_search },
    PmenuKind = { fg = c.fg_dim },
    PmenuExtra = { fg = c.fg },
    PmenuSbar = { bg = c.fg_reverse },
    PmenuThumb = { bg = c.bg_search },
    PmenuBorder = { fg = c.bg_search, bg = c.fg_reverse },
    Question = { link = "MoreMsg" },
    QuickFixLine = { bg = c.bg_p1 },
    Search = { fg = c.fg, bg = c.bg_search },
    SpecialKey = { fg = c.special },
    SpellBad = { undercurl = true, sp = c.error },
    SpellCap = { undercurl = true, sp = c.warning },
    SpellLocal = { undercurl = true, sp = c.warning },
    SpellRare = { undercurl = true, sp = c.warning },
    StatusLine = { fg = c.fg_dim, bg = c.bg },
    StatusLineNC = { fg = c.nontext, bg = c.bg },
    TabLine = { fg = c.special, bg = c.bg_m3 },
    TabLineFill = { bg = c.bg },
    TabLineSel = { fg = c.fg_dim, bg = c.bg_p1 },
    Title = { fg = c.fun, bold = true },
    Visual = { bg = c.bg_visual },
    WarningMsg = { fg = c.warning },
    WildMenu = { link = "Pmenu" },
    WinBar = { fg = c.fg_dim },
    WinBarNC = { fg = c.fg_dim },
    debugPC = { bg = c.diff_delete },
    debugBreakpoint = { fg = c.special1 },

    -- lsp
    LspReferenceText = { bg = c.diff_text },
    LspReferenceWrite = { bg = c.diff_text, underline = true },
    LspSignatureActiveParameter = { fg = c.warning },
    LspCodeLens = { fg = c.comment },

    -- diff / git
    diffAdded = { fg = c.added },
    diffRemoved = { fg = c.removed },
    diffDeleted = { fg = c.removed },
    diffChanged = { fg = c.changed },
    diffOldFile = { fg = c.removed },
    diffNewFile = { fg = c.added },
    ["@diff.plus"] = { fg = c.added },
    ["@diff.minus"] = { fg = c.removed },
    ["@diff.delta"] = { fg = c.changed },

    -- syntax
    Comment = { fg = c.comment, italic = true },
    Constant = { fg = c.constant },
    String = { fg = c.string },
    Character = { link = "String" },
    Number = { fg = c.number },
    Boolean = { fg = c.constant, bold = true },
    Identifier = { fg = c.identifier },
    Function = { fg = c.fun },
    Statement = { fg = c.keyword, bold = true },
    Operator = { fg = c.operator },
    Keyword = { fg = c.keyword, italic = true },
    Exception = { fg = c.special2 },
    PreProc = { fg = c.preproc },
    Type = { fg = c.type },
    Special = { fg = c.special1 },
    Delimiter = { fg = c.punct },
    Underlined = { fg = c.special1, underline = true },
    Ignore = { link = "NonText" },
    Error = { fg = c.error },
    Todo = { fg = c.fg_reverse, bg = c.info, bold = true },
    markdownCode = { fg = c.string },
    markdownCodeBlock = { fg = c.string },
    markdownEscape = {},

    -- treesitter
    ["@variable"] = { fg = c.fg },
    ["@variable.builtin"] = { fg = c.special2, italic = true },
    ["@variable.parameter"] = { fg = c.parameter },
    ["@variable.member"] = { fg = c.identifier },
    ["@string.regexp"] = { fg = c.operator },
    ["@string.escape"] = { fg = c.operator, bold = true },
    ["@string.special.symbol"] = { fg = c.identifier },
    ["@string.special.url"] = { fg = c.special1, undercurl = true },
    ["@attribute"] = { link = "Constant" },
    ["@function.macro"] = { link = "Macro" },
    ["@constructor.lua"] = { fg = c.keyword },
    ["@keyword.operator"] = { fg = c.operator, bold = true },
    ["@keyword.import"] = { link = "PreProc" },
    ["@keyword.return"] = { fg = c.special3, italic = true },
    ["@keyword.exception"] = { fg = c.special3, bold = true },
    ["@keyword.luap"] = { link = "String" },
    ["@punctuation.delimiter"] = { fg = c.punct },
    ["@punctuation.bracket"] = { fg = c.punct },
    ["@comment.error"] = { fg = c.fg, bg = c.error, bold = true },
    ["@comment.warning"] = { fg = c.fg_reverse, bg = c.warning, bold = true },
    ["@comment.note"] = { fg = c.fg_reverse, bg = c.hint, bold = true },
    ["@markup.heading"] = { link = "Function" },
    ["@markup.quote"] = { link = "@variable.parameter" },
    ["@markup.math"] = { link = "Constant" },
    ["@markup.environment"] = { link = "Keyword" },
    ["@markup.link.url"] = { link = "@string.special.url" },
    ["@markup.raw"] = { link = "String" },
    ["@tag.attribute"] = { fg = c.identifier },
    ["@tag.delimiter"] = { fg = c.punct },

    -- lsp semantic tokens
    ["@lsp.type.macro"] = { link = "Macro" },
    ["@lsp.type.variable"] = {},
    ["@lsp.type.const"] = { link = "Constant" },
    ["@lsp.type.comparison"] = { link = "Operator" },
    ["@lsp.type.bitwise"] = { link = "Operator" },
    ["@lsp.type.punctuation"] = { link = "Delimiter" },
    ["@lsp.type.selfParameter"] = { link = "@variable.builtin" },
    ["@lsp.type.builtinConstant"] = { link = "@constant.builtin" },
    ["@lsp.type.magicFunction"] = { link = "@function.builtin" },
    ["@lsp.type.lifetime"] = { link = "Operator" },
    ["@lsp.type.decorator.rust"] = { link = "PreProc" },
    ["@lsp.mod.readonly"] = { link = "Constant" },
    ["@lsp.mod.typeHint"] = { link = "Type" },
    ["@lsp.mod.deprecated"] = { fg = c.comment, strikethrough = true },
    ["@lsp.typemod.operator.controlFlow"] = { link = "@keyword.exception" },
    ["@lsp.typemod.keyword.documentation"] = { link = "Special" },
    ["@lsp.typemod.variable.global"] = { link = "Constant" },
    ["@lsp.typemod.variable.static"] = { link = "Constant" },
    ["@lsp.typemod.variable.defaultLibrary"] = { link = "Special" },
    ["@lsp.typemod.variable.injected"] = { link = "@variable" },
    ["@lsp.typemod.function.builtin"] = { link = "@function.builtin" },
    ["@lsp.typemod.function.defaultLibrary"] = { link = "@function.builtin" },
    ["@lsp.typemod.method.defaultLibrary"] = { link = "@function.builtin" },
    ["@lsp.typemod.function.readonly"] = { fg = c.fun, bold = true },

    -- plugins
    GitSignsAdd = { fg = c.added },
    GitSignsChange = { fg = c.changed },
    GitSignsDelete = { fg = c.removed },
    TreesitterContext = { link = "Folded" },
    TreesitterContextLineNumber = { fg = c.special },
    TelescopeBorder = { fg = c.nontext, bg = c.bg },
    TelescopeTitle = { fg = c.special },
    TelescopeSelection = { link = "CursorLine" },
    TelescopeSelectionCaret = { link = "CursorLineNr" },
    TelescopeResultsClass = { link = "Structure" },
    TelescopeResultsStruct = { link = "Structure" },
    TelescopeResultsField = { link = "@field" },
    TelescopeResultsMethod = { link = "Function" },
    TelescopeResultsVariable = { link = "@variable" },
    MiniIconsAzure = { fg = c.special1 },
    MiniIconsBlue = { fg = c.fun },
    MiniIconsCyan = { fg = c.type },
    MiniIconsGreen = { fg = c.string },
    MiniIconsGrey = { fg = c.fg },
    MiniIconsOrange = { fg = c.constant },
    MiniIconsPurple = { fg = c.keyword },
    MiniIconsRed = { fg = c.special3 },
    MiniIconsYellow = { fg = c.identifier },
}

-- floating, sign and virtual text groups link to these by default
hl.DiagnosticOk = { fg = c.ok }
local diagnostics = { Error = c.error, Warn = c.warning, Info = c.info, Hint = c.hint }
for severity, color in pairs(diagnostics) do
    hl["Diagnostic" .. severity] = { fg = color }
    hl["DiagnosticUnderline" .. severity] = { undercurl = true, sp = color }
end

for group, opts in pairs(hl) do
    vim.api.nvim_set_hl(0, group, opts)
end

for i, color in ipairs({
    c.bg_m3,
    c.removed,
    c.added,
    c.operator,
    c.fun,
    c.keyword,
    c.hint,
    c.fg_dim,
    c.comment,
    c.error,
    c.string,
    c.identifier,
    c.special1,
    c.special,
    c.type,
    c.fg,
    c.constant,
    c.special3,
}) do
    vim.g["terminal_color_" .. i - 1] = color
end
