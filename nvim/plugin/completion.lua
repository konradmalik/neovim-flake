vim.o.shortmess = vim.o.shortmess .. "c"
vim.o.completeopt = "menuone,noinsert,noselect,popup,fuzzy"
vim.o.complete = "o,.,w,b,u"
vim.o.autocomplete = true
vim.o.autocompletedelay = 200

local sanitizer = vim.api.nvim_create_augroup("pde-completion-sanitizer", { clear = true })

---@param buf integer
local function no_autocomplete_in_special(buf)
    if vim.bo[buf].buftype ~= "" then vim.bo[buf].autocomplete = false end
end

vim.api.nvim_create_autocmd("BufNew", {
    group = sanitizer,
    callback = function(ev) no_autocomplete_in_special(ev.buf) end,
})

-- some special buffers only get their buftype after BufNew has fired
vim.api.nvim_create_autocmd("OptionSet", {
    group = sanitizer,
    pattern = "buftype",
    callback = function(ev) no_autocomplete_in_special(ev.buf) end,
})

vim.o.completefunc = "v:lua.require'incomplete'.completefunc"

local file_completion_keys = vim.keycode("<C-x><C-f>")

---Trigger built-in file completion with the current-directory prepared one way or
---the other. Both mappings work at any point of an insert session, including while
---a completion popup is open, so the two switch back and forth rather than set a
---mode that has to be unset again.
---@param prepare fun(buf: integer)
---@return fun()
local function complete_path(prepare)
    return function()
        prepare(vim.api.nvim_get_current_buf())
        vim.api.nvim_feedkeys(file_completion_keys, "n", false)
    end
end

-- Keeps the built-in meaning, but cannot just be left unmapped: a swap lasts until
-- insert mode ends, so after one CTRL-X CTRL-G this would silently stay relative to
-- the current file for the rest of the session.
vim.keymap.set("i", "<C-x><C-f>", complete_path(require("pde.bufdir").restore), {
    desc = "File name completion relative to the project root",
})
-- CTRL-X CTRL-G is one of the few pairs free in CTRL-X submode, see :h i_CTRL-X_index
vim.keymap.set("i", "<C-x><C-g>", complete_path(require("pde.bufdir").use), {
    desc = "File name completion relative to the current file",
})
