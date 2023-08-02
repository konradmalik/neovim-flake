local capabilities = vim.lsp.protocol.make_client_capabilities()

-- cmp provides more capabilites
local cmp_nvim_lsp = require("cmp_nvim_lsp")
local cmp_capabilities = cmp_nvim_lsp.default_capabilities()
capabilities = vim.tbl_deep_extend('force', capabilities, cmp_capabilities)

-- Enable (broadcasting) snippet capability for completion
capabilities.textDocument.completion.completionItem.snippetSupport = true

return capabilities
