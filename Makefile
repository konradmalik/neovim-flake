# the lua is linted per directory because each has its own .luarc.json
LUA_DIRS := nvim spec

# --others so a new file is checked before it is ever staged, and wildcard
# to drop what git still has in the index but is gone from disk
GIT_LS := git ls-files --cached --others --exclude-standard
LUA_FILES := $(wildcard $(shell $(GIT_LS) '*.lua'))
NIX_FILES := $(wildcard $(shell $(GIT_LS) '*.nix'))
SH_FILES := $(wildcard $(shell $(GIT_LS) '*.sh'))
# what prettier is left to cover once the three above have had their turn
PRETTIER_FILES := $(wildcard $(shell $(GIT_LS) '*.json' '*.md' '*.yaml' '*.yml'))

# an empty list would make a fmt check pass over nothing at all
$(foreach v,LUA_FILES NIX_FILES SH_FILES PRETTIER_FILES,\
  $(if $(strip $($(v))),,$(error $(v) is empty, run make from the repo root)))

.PHONY: check
check: check-fmt check-lint

.PHONY: fmt
fmt: fmt-nix fmt-lua fmt-sh fmt-prettier

.PHONY: fmt-nix
fmt-nix:
	@nixfmt $(NIX_FILES)

.PHONY: fmt-lua
fmt-lua:
	@stylua $(LUA_FILES)

.PHONY: fmt-sh
fmt-sh:
	@shfmt -w $(SH_FILES)

.PHONY: fmt-prettier
fmt-prettier:
	@prettier --write --log-level warn $(PRETTIER_FILES)

.PHONY: check-fmt
check-fmt: check-fmt-nix check-fmt-lua check-fmt-sh check-fmt-prettier

.PHONY: check-fmt-nix
check-fmt-nix:
	@nixfmt --check $(NIX_FILES)

.PHONY: check-fmt-lua
check-fmt-lua:
	@stylua --check $(LUA_FILES)

# shfmt takes its indent from .editorconfig, same as the editor does
.PHONY: check-fmt-sh
check-fmt-sh:
	@shfmt -d $(SH_FILES)

.PHONY: check-fmt-prettier
check-fmt-prettier:
	@prettier --check --log-level warn $(PRETTIER_FILES)

.PHONY: check-lint
check-lint: lint-lua lint-sh

.PHONY: lint-lua
lint-lua: luacheck typecheck

.PHONY: luacheck
luacheck:
	@luacheck --codes --no-cache $(LUA_DIRS)

.PHONY: typecheck
typecheck:
	@for dir in $(LUA_DIRS); do nvim-typecheck ./$$dir || exit 1; done

.PHONY: lint-sh
lint-sh:
	@shellcheck $(SH_FILES)

.PHONY: test
test:
	@busted
