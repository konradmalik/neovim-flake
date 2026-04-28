local toggles = {
    ["true"] = "false",
    ["always"] = "never",
    ["yes"] = "no",
    ["on"] = "off",
}

local lookup = {}
for a, b in pairs(toggles) do
    lookup[a] = b
    lookup[b] = a
end

---@param s string word to check
---@return boolean
local function is_title_case(s)
    return s:sub(1, 1) == s:sub(1, 1):upper() and s:sub(2) == s:sub(2):lower()
end

---@param s string
---@return string
local function make_title_case(s) return (s:gsub("^%l", string.upper)) end

--- Apply the casing of `original` to `word`.
local function apply_case(original, word)
    if original == original:upper() then
        return word:upper()
    elseif is_title_case(original) then
        return make_title_case(word)
    end
    return word
end

---@return boolean returns true if matched, false if should fallback,
local function toggle()
    local cword = vim.fn.expand("<cword>")
    local new_word = lookup[cword]

    if not new_word then
        local match = lookup[cword:lower()]
        if match then new_word = apply_case(cword, match) end
    end

    if new_word then
        vim.cmd.normal({ '"_ciw' .. new_word, bang = true })
        vim.cmd.normal({ "be", bang = true })
        return true
    end

    return false
end

vim.keymap.set("n", "<C-a>", function()
    if not toggle() then
        local key = vim.api.nvim_replace_termcodes("<C-a>", true, false, true)
        vim.cmd.normal({ key, bang = true })
    end
end)
vim.keymap.set("n", "<C-x>", function()
    if not toggle() then
        local key = vim.api.nvim_replace_termcodes("<C-x>", true, false, true)
        vim.cmd.normal({ key, bang = true })
    end
end)
