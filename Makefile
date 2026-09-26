LUA_DIRS := nvim spec

# --others so a new file is checked before it is ever staged, and wildcard
# to drop what git still has in the index but is gone from disk
GIT_LS := git ls-files --cached --others --exclude-standard
NIX_FILES := $(wildcard $(shell $(GIT_LS) '*.nix'))

# an empty list would make the nix fmt check pass over nothing at all
ifeq ($(NIX_FILES),)
$(error no nix files found, run make from the repo root)
endif

.PHONY: check
check: check-fmt check-lint

.PHONY: fmt
fmt: fmt-nix fmt-lua

.PHONY: fmt-nix
fmt-nix:
	@nixfmt $(NIX_FILES)

.PHONY: fmt-lua
fmt-lua:
	@stylua .

.PHONY: check-fmt
check-fmt: check-fmt-nix check-fmt-lua

# nixfmt walks into .direnv and result if handed a directory, so pass the files
.PHONY: check-fmt-nix
check-fmt-nix:
	@nixfmt --check $(NIX_FILES)

# stylua respects .gitignore, so a bare . already skips those
.PHONY: check-fmt-lua
check-fmt-lua:
	@stylua --check .

.PHONY: check-lint
check-lint: luacheck typecheck

.PHONY: luacheck
luacheck:
	@luacheck --codes --no-cache $(LUA_DIRS)

.PHONY: typecheck
typecheck:
	@for dir in $(LUA_DIRS); do nvim-typecheck ./$$dir || exit 1; done

.PHONY: test
test:
	@busted
