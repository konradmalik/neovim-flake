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
