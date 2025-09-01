local nvim = vim.lsp.protocol.make_client_capabilities()

local blink = require("blink.cmp").get_lsp_capabilities(
    -- FIXME: https://github.com/neovim/neovim/pull/34637
    { textDocument = { onTypeFormatting = { dynamicRegistration = false } } },
    false
)

return vim.tbl_deep_extend("force", nvim, blink)
