{ pkgs, appName, colorscheme }:
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
  colorscheme-lua = pkgs.callPackage ./nix/lua/konrad/colorscheme.nix { inherit colorscheme; };
  dap-cs-lua = pkgs.callPackage ./nix/lua/konrad/dap/configurations/cs.nix { };
  dap-go-lua = pkgs.callPackage ./nix/lua/konrad/dap/configurations/go.nix { };
  dap-python-lua = pkgs.callPackage ./nix/lua/konrad/dap/configurations/python.nix { };
  lsp-jsonls-lua = pkgs.callPackage ./nix/lua/konrad/lsp/settings/jsonls.nix { };
  lsp-yamlls-lua = pkgs.callPackage ./nix/lua/konrad/lsp/settings/yamlls.nix { };
  lsp-nullls-lua = pkgs.callPackage ./nix/lua/konrad/lsp/null-ls.nix { };
in
pkgs.symlinkJoin {
  name = "${appName}-config";
  paths = [
    nativeConfig
    colorscheme-lua
    dap-cs-lua
    dap-go-lua
    dap-python-lua
    lsp-jsonls-lua
    lsp-yamlls-lua
    lsp-nullls-lua
  ];
}
