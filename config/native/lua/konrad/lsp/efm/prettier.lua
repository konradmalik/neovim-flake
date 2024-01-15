local binaries = require("konrad.binaries")

return {
	filetypes = {
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
		"vue",
		"css",
		"scss",
		"less",
		"html",
		"json",
		"jsonc",
		"yaml",
		"markdown",
		"markdown.mdx",
		"graphql",
		"handlebars",
	},
	entry = {
		formatCommand = {
			binaries.prettier(),
			"--stdin",
			"--stdin-filepath",
			"'${INPUT}'",
			"${--range-start:charStart}",
			"${--range-end:charEnd}",
			"${--tab-width:tabSize}",
			"${--use-tabs:!insertSpaces}",
		},
		formatStdin = true,
		formatCanRange = true,
		rootMarkers = {
			".prettierrc",
			".prettierrc.json",
			".prettierrc.js",
			".prettierrc.yml",
			".prettierrc.yaml",
			".prettierrc.json5",
			".prettierrc.mjs",
			".prettierrc.cjs",
			".prettierrc.toml",
		},
	},
}
