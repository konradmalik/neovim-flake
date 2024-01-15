local binaries = require("konrad.binaries")
require("copilot").setup({
	suggestion = { enabled = false },
	panel = { enabled = false },
	copilot_node_command = binaries.node(),
})

require("copilot_cmp").setup()
