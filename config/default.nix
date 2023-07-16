{ pkgs, lib, appName, isolated }:
let
  nativeConfig = pkgs.stdenv.mkDerivation {
    name = "${appName}-native-config";
    src = ./.;
    installPhase = ''
      mkdir -p $out/
      cp -r $src/native/* $out/
    '';
  };
  # manually handle nix templates to avoid IFD
  cmp-copilot-lua = pkgs.callPackage ./nix/lua/konrad/cmp/copilot.nix { };
  dap-cs-lua = pkgs.callPackage ./nix/lua/konrad/dap/configurations/cs.nix { };
  dap-go-lua = pkgs.callPackage ./nix/lua/konrad/dap/configurations/go.nix { };
  dap-python-lua = pkgs.callPackage ./nix/lua/konrad/dap/configurations/python.nix { };
  lsp-efm-lua = pkgs.callPackage ./nix/lua/konrad/lsp/efm/init.nix { };
  lsp-efm-jq-lua = pkgs.callPackage ./nix/lua/konrad/lsp/efm/jq.nix { };
  lsp-efm-prettier-lua = pkgs.callPackage ./nix/lua/konrad/lsp/efm/prettier.nix { };
  lsp-efm-shellcheck-lua = pkgs.callPackage ./nix/lua/konrad/lsp/efm/shellcheck.nix { };
  lsp-jsonls-lua = pkgs.callPackage ./nix/lua/konrad/lsp/settings/jsonls.nix { };
  lsp-yamlls-lua = pkgs.callPackage ./nix/lua/konrad/lsp/settings/yamlls.nix { };
  lsp-nullls-lua = pkgs.callPackage ./nix/lua/konrad/lsp/null-ls.nix { };
in
pkgs.symlinkJoin {
  name = "${appName}-config";
  paths = [
    nativeConfig
    cmp-copilot-lua
    dap-cs-lua
    dap-go-lua
    dap-python-lua
    lsp-efm-lua
    lsp-efm-jq-lua
    lsp-efm-prettier-lua
    lsp-efm-shellcheck-lua
    lsp-jsonls-lua
    lsp-yamlls-lua
    lsp-nullls-lua
  ];
  # config structure:
  # - if isolated is false, then $out/init.lua. This is for home-manager
  # - if isolated is true, then $out/${appName}/init.lua. This is for 'nix run .' etc where we override XDG_CONFIG_HOME
  #   and the expected structure is the same as XDG_CONFIG_HOME
  # postBuild below rusn if isolated and it's purpose is to create XDG_CONFIG_HOME-like folder structure
  postBuild = lib.optionalString isolated ''
    mkdir $out/${appName}
    shopt -s extglob dotglob
    mv $out/!(${appName}) $out/${appName}
    shopt -u dotglob
  '';
}
