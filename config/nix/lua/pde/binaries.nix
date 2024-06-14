{ lib, pkgs }:
let
  debugpy = pkgs.python3.withPackages (p: [ p.debugpy ]);
in
pkgs.writeTextDir "lua/pde/binaries.lua" # lua
  ''
    local fs = require("pde.fs")
    return {
        -- formatters
        black = function() return fs.from_path_or_default("black", "${lib.getExe pkgs.black}") end,
        isort = function() return fs.from_path_or_default("isort", "${lib.getExe pkgs.isort}") end,
        nixfmt = function() return "${lib.getExe pkgs.nixfmt-rfc-style}" end,
        prettier = function() return fs.from_path_or_default("prettier", "${lib.getExe pkgs.nodePackages.prettier}") end,
        rustfmt = function() return "${lib.getExe pkgs.rustfmt}" end,
        shfmt = function() return "${lib.getExe pkgs.shfmt}" end,
        stylua = function() return fs.from_path_or_default("stylua", "${lib.getExe pkgs.stylua}") end,
        taplo = function() return fs.from_path_or_default("taplo", "${lib.getExe pkgs.taplo}") end,

        -- linters
        golangci_lint = function() return fs.from_path_or_default("golangci-lint", "${lib.getExe pkgs.golangci-lint}") end,
        jq = function() return "${lib.getExe pkgs.jq}" end,
        shellcheck = function() return "${lib.getExe pkgs.shellcheck}" end,

        -- lsps
        clangd = function() return "${lib.getExe pkgs.clang-tools}" end,
        efm = function() return '${lib.getExe pkgs.efm-langserver}' end,
        gopls = function() return "${lib.getExe pkgs.gopls}" end,
        jsonls = function() return "${lib.getExe pkgs.nodePackages.vscode-json-languageserver}" end,
        ltex_ls = function() return "${lib.getExe' pkgs.ltex-ls "ltex-ls"}" end,
        lua_ls = function() return "${lib.getExe pkgs.lua-language-server}" end,
        nixd = function() return "${lib.getExe pkgs.nixd}" end,
        pyright = function() return "${lib.getExe pkgs.pyright}" end,
        roslyn_ls = function() return "${lib.getExe pkgs.roslyn-ls}" end,
        rust_analyzer = function() return "${lib.getExe pkgs.rust-analyzer}" end,
        terraformls = function() return "${lib.getExe pkgs.terraform-ls}" end,
        yamlls = function() return "${lib.getExe pkgs.yaml-language-server}" end,
        zls = function() return "${lib.getExe pkgs.zls}" end,

        -- debuggers
        debugpy = function() return '${debugpy}/bin/python' end,
        delve = function() return '${lib.getExe' pkgs.delve "dap"}' end,
        netcoredbg = function() return '${lib.getExe pkgs.netcoredbg}' end,

        -- other
        node = function() return '${lib.getExe pkgs.nodejs-slim}' end,
    }
  ''
