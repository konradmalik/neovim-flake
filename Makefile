.PHONY: luacheck
luacheck:
	@luacheck --codes --no-cache ./config/native

.PHONY: fmt
fmt:
	@stylua .
