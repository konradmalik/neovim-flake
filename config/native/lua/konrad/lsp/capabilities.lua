local capabilities = vim.lsp.protocol.make_client_capabilities()

-- cmp provides more capabilites
local cmp_nvim_lsp = require("cmp_nvim_lsp")
capabilities = cmp_nvim_lsp.default_capabilities(capabilities)

-- Enable (broadcasting) snippet capability for completion
capabilities.textDocument.completion.completionItem.snippetSupport = true

return capabilities
