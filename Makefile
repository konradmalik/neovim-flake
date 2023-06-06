ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

.PHONY: live
live:
	@XDG_CONFIG_DIR="$(ROOT_DIR)/config/native" \
		NVIM_APPNAME=neovim-pde \
		nvim
