-- Quiet dark colorscheme with the palette of https://codeberg.org/navahas/sanzo.nvim
-- Text stays bone, only roles get color. Each accent has a nearby sibling:
-- function / library function, type / builtin, string / definition,
-- constant / return, keyword / control flow.

vim.o.background = "dark"
vim.cmd.highlight("clear")
vim.g.colors_name = "sanzo"

local p = {
    bg = "#2b2a2a",
    sel = "#404040",
    vis = "#4d4d4d",

    -- bone
    fg = "#e8e8d3",
    param = "#d7d7c6",

    -- grey
    op = "#bcbcb2",
    punct = "#acaca2",
    comment = "#7a7a7a",
    grey = "#6f6f6b",
    grey_ui = "#5a5a5a",
    grey_dim = "#3a3a3a",

    -- accent / sibling
    fn = "#dcbd93",
    fn_lib = "#cebfa1",
    type = "#93a5a0",
    builtin = "#859099",
    string = "#a8bcac",
    def = "#a8b0b8",
    const = "#cca598",
    ret = "#cc9a98",
    keyword = "#b3a6b0",
    ctrl = "#9e8f9c",
}

---@type table<string, vim.api.keyset.highlight>
local hl = {
    -- editor
    Normal = { fg = p.fg, bg = p.bg },
    NormalFloat = { fg = p.fg, bg = p.bg },
    FloatBorder = { fg = p.punct, bg = p.bg },
    FloatTitle = { fg = p.fg, bg = p.bg },
    SignColumn = { bg = p.bg },
    EndOfBuffer = { fg = p.grey_ui },
    ColorColumn = { bg = p.grey_dim },
    CursorLine = {},
    CursorColumn = {},
    Cursor = { fg = p.bg, bg = p.fg },
    LineNr = { fg = p.grey_ui },
    CursorLineNr = { fg = p.fg },
    Visual = { bg = p.vis },
    Search = { fg = p.bg, bg = p.string },
    IncSearch = { fg = p.bg, bg = p.fn },
    CurSearch = { link = "IncSearch" },
    MatchParen = { fg = p.fn, bold = true },
    WinSeparator = { fg = p.punct },
    NonText = { fg = p.grey_dim },
    SpecialKey = { link = "NonText" },
    Directory = { fg = p.fn },
    Title = { fg = p.fn, bold = true },
    Folded = { fg = p.grey, italic = true },
    Conceal = { fg = p.grey },
    WinBar = { fg = p.fg },
    WinBarNC = { fg = p.grey },
    QuickFixLine = { bg = p.sel },
    StatusLine = { fg = p.grey_ui },
    StatusLineNC = { fg = p.grey_dim },
    TabLineSel = { fg = p.keyword, bold = true },
    TabLineFill = { fg = p.grey },

    -- messages
    ModeMsg = { fg = p.fn, bold = true },
    MoreMsg = { fg = p.string },
    Question = { fg = p.string },
    ErrorMsg = { fg = p.const, bold = true },
    WarningMsg = { fg = p.fn },
    MsgSeparator = { fg = p.grey },

    -- popup menu
    Pmenu = { fg = p.fg, bg = p.bg },
    PmenuSel = { fg = p.fn, bg = p.sel, bold = true },
    PmenuSbar = {},
    PmenuThumb = { bg = p.grey },
    PmenuKind = { fg = p.def },
    PmenuKindSel = { fg = p.def, bg = p.sel, bold = true },
    PmenuExtra = { fg = p.grey },
    PmenuExtraSel = { fg = p.grey, bg = p.sel },
    PmenuBorder = { link = "FloatBorder" },

    -- lsp
    LspInlayHint = { fg = p.grey },
    LspSignatureActiveParameter = { fg = p.keyword, bold = true },
    LspReferenceText = { bg = p.sel },

    -- diff / git
    DiffAdd = { fg = p.string },
    DiffChange = { fg = p.def },
    DiffDelete = { fg = p.const },
    DiffText = { fg = p.fn },
    Added = { fg = p.string },
    Changed = { fg = p.def },
    Removed = { fg = p.const },

    -- spell
    SpellBad = { undercurl = true, sp = p.const },
    SpellCap = { undercurl = true, sp = p.fn },
    SpellRare = { undercurl = true, sp = p.keyword },
    SpellLocal = { undercurl = true, sp = p.def },

    -- syntax, treesitter captures fall back to these
    Comment = { fg = p.comment, italic = true },
    Constant = { fg = p.builtin },
    String = { fg = p.string },
    Character = { link = "String" },
    Number = { fg = p.const },
    Boolean = { link = "Number" },
    Identifier = { fg = p.fg },
    Function = { fg = p.fn },
    Statement = { fg = p.keyword },
    Conditional = { fg = p.ctrl },
    Repeat = { fg = p.ctrl },
    Label = { fg = p.ctrl },
    Exception = { fg = p.ctrl },
    Operator = { fg = p.op },
    PreProc = { fg = p.def },
    Type = { fg = p.type },
    Special = { fg = p.string },
    Delimiter = { fg = p.punct },
    Underlined = { fg = p.def, underline = true },
    Error = { fg = p.const },
    Todo = { fg = p.bg, bg = p.fn, bold = true },

    -- treesitter
    ["@variable"] = { fg = p.fg },
    ["@variable.builtin"] = { fg = p.builtin },
    ["@variable.parameter"] = { fg = p.param },
    ["@constructor"] = { fg = p.fg },
    ["@constant.builtin"] = { fg = p.const },
    ["@module"] = { fg = p.def },
    ["@function.builtin"] = { fg = p.fn_lib },
    ["@function.macro"] = { fg = p.def },
    ["@type.builtin"] = { fg = p.builtin },
    ["@keyword.import"] = { fg = p.ctrl },
    ["@keyword.conditional"] = { fg = p.ctrl },
    ["@keyword.repeat"] = { fg = p.ctrl },
    ["@keyword.exception"] = { fg = p.ctrl },
    ["@keyword.coroutine"] = { fg = p.ctrl },
    ["@keyword.return"] = { fg = p.ret },
    ["@keyword.directive"] = { fg = p.def },
    ["@punctuation.special"] = { fg = p.op },
    ["@tag"] = { fg = p.keyword },
    ["@tag.attribute"] = { fg = p.string },
    ["@tag.delimiter"] = { fg = p.punct },
    ["@markup.link.url"] = { fg = p.grey, underline = true },
    ["@markup.raw"] = { link = "String" },
    ["@markup.quote"] = { link = "Comment" },

    -- lsp semantic tokens
    ["@lsp.type.macro"] = { fg = p.def },
    ["@lsp.type.enumMember"] = { fg = p.const },
    ["@lsp.type.builtinType"] = { fg = p.builtin },
    ["@lsp.type.selfKeyword"] = { fg = p.builtin },
    ["@lsp.typemod.function.defaultLibrary"] = { link = "@function.builtin" },
    ["@lsp.typemod.method.defaultLibrary"] = { link = "@function.builtin" },
    ["@lsp.typemod.type.defaultLibrary"] = { link = "@type.builtin" },
    ["@lsp.mod.deprecated"] = { strikethrough = true },
}

local diagnostics = { Error = p.const, Warn = p.fn, Info = p.def, Hint = p.grey, Ok = p.string }
for severity, color in pairs(diagnostics) do
    hl["Diagnostic" .. severity] = { fg = color }
    hl["DiagnosticUnderline" .. severity] = { undercurl = true, sp = color }
end

for group, opts in pairs(hl) do
    vim.api.nvim_set_hl(0, group, opts)
end
