local gitsigns = require("gitsigns")
gitsigns.setup({
	signs = {
		add = { text = "+" },
		change = { text = "~" },
		delete = { text = "-" },
		topdelete = { text = "‾" },
		changedelete = { text = "~" },
	},
	signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
	numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
	linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
	word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
	current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`

	on_attach = function(bufnr)
		vim.cmd("redrawstatus")
		local opts = { noremap = true, buffer = bufnr }
		local opts_with_desc = function(desc) return vim.tbl_extend("error", opts, { desc = "[Gitsigns] " .. desc }) end

		vim.keymap.set("n", "<leader>gj", gitsigns.next_hunk, opts_with_desc("Next Hunk"))
		vim.keymap.set("n", "<leader>gk", gitsigns.prev_hunk, opts_with_desc("Prev Hunk"))
		vim.keymap.set("n", "<leader>gp", gitsigns.preview_hunk, opts_with_desc("Preview Hunk"))
		vim.keymap.set("n", "<leader>gr", gitsigns.reset_hunk, opts_with_desc("Reset Hunk"))
		vim.keymap.set("n", "<leader>gR", gitsigns.reset_buffer, opts_with_desc("Reset Buffer"))
		vim.keymap.set("n", "<leader>gs", gitsigns.stage_hunk, opts_with_desc("Stage Hunk"))
		vim.keymap.set("n", "<leader>gu", gitsigns.undo_stage_hunk, opts_with_desc("Undo Stage Hunk"))
	end,
})
