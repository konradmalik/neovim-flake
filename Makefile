.PHONY: luacheck
luacheck:
	@luacheck --codes --no-cache ./config/nvim

.PHONY: typecheck
typecheck:
	@nvim-typecheck ./config/nvim

.PHONY: fmt
fmt:
	@stylua .

.PHONY: check-fmt
check-fmt:
	@stylua --check .

.PHONY: check-lint
check-lint: luacheck typecheck

.PHONY: test
test:
	@busted

