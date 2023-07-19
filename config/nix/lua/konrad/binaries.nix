{ pkgs }:
let
  debugpy = pkgs.python3.withPackages (p: [ p.debugpy ]);
in
pkgs.writeTextDir "lua/konrad/binaries.lua" ''
  return {
      debugpy = '${debugpy}/bin/python',
      delve = '${pkgs.delve}/bin/dap',
      efm = '${pkgs.efm-langserver}/bin/efm-langserver',
      jsonls = "${pkgs.nodePackages.vscode-json-languageserver}/bin/vscode-json-languageserver",
      jq = "${pkgs.jq}/bin/jq",
      netcoredbg = '${pkgs.netcoredbg}/bin/netcoredbg',
      node = '${pkgs.nodejs-slim}/bin/node',
      prettier = "${pkgs.nodePackages.prettier}/bin/prettier",
      prettier_plugin_toml = "${pkgs.nodePackages.prettier-plugin-toml}/lib",
      shellcheck = "${pkgs.shellcheck}/bin/shellcheck",
      shfmt = "${pkgs.shfmt}/bin/shfmt",
      yamlls = "${pkgs.nodePackages.yaml-language-server}/bin/yaml-language-server",
  }
''
