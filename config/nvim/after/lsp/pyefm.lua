local config = require("pde.lsp.configs.efm").config_from_multi("pyefm", { "black", "isort" })
config.filetypes = { "python" }
return config
