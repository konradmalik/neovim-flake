{ pkgs }:
let
  debugpy = pkgs.python3.withPackages (p: [ p.debugpy ]);
in
pkgs.writeTextDir "lua/pde/binaries.lua" /* lua */ ''
  local fs = require("pde.fs")
  return {
      -- formatters
      black = function() return fs.from_path_or_default("black", "${pkgs.black}/bin/black") end,
      isort = function() return fs.from_path_or_default("isort", "${pkgs.isort}/bin/isort") end,
      nixfmt = function() return "${pkgs.nixfmt-rfc-style}/bin/nixfmt" end,
      prettier = function() return fs.from_path_or_default("prettier", "${pkgs.nodePackages.prettier}/bin/prettier") end,
      rustfmt = function() return "${pkgs.rustfmt}/bin/rustfmt" end,
      shfmt = function() return "${pkgs.shfmt}/bin/shfmt" end,
      stylua = function() return fs.from_path_or_default("stylua", "${pkgs.stylua}/bin/stylua") end,
      taplo = function() return fs.from_path_or_default("taplo", "${pkgs.taplo}/bin/taplo") end,

      -- linters
      golangci_lint = function() return fs.from_path_or_default("golangci-lint", "${pkgs.golangci-lint}/bin/golangci-lint") end,
      jq = function() return "${pkgs.jq}/bin/jq" end,
      shellcheck = function() return "${pkgs.shellcheck}/bin/shellcheck" end,

      -- lsps
      clangd = function() return "${pkgs.clang-tools}/bin/clangd" end,
      efm = function() return '${pkgs.efm-langserver}/bin/efm-langserver' end,
      gopls = function() return "${pkgs.gopls}/bin/gopls" end,
      jsonls = function() return "${pkgs.nodePackages.vscode-json-languageserver}/bin/vscode-json-languageserver" end,
      ltex_ls = function() return "${pkgs.ltex-ls}/bin/ltex-ls" end,
      lua_ls = function() return "${pkgs.sumneko-lua-language-server}/bin/lua-language-server" end,
      nixd = function() return "${pkgs.nixd}/bin/nixd" end,
      pyright = function() return "${pkgs.nodePackages.pyright}/bin/pyright-langserver" end,
      roslyn_ls = function() return "${pkgs.roslyn-ls}/bin/Microsoft.CodeAnalysis.LanguageServer" end,
      rust_analyzer = function() return "${pkgs.rust-analyzer}/bin/rust-analyzer" end,
      terraformls = function() return "${pkgs.terraform-ls}/bin/terraform-ls" end,
      yamlls = function() return "${pkgs.nodePackages.yaml-language-server}/bin/yaml-language-server" end,
      zls = function() return "${pkgs.zls}/bin/zls" end,

      -- debuggers
      debugpy = function() return '${debugpy}/bin/python' end,
      delve = function() return '${pkgs.delve}/bin/dap' end,
      netcoredbg = function() return '${pkgs.netcoredbg}/bin/netcoredbg' end,

      -- other
      node = function() return '${pkgs.nodejs-slim}/bin/node' end,
  }
''
